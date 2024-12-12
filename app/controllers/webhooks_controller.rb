class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.configuration.stripe[:webhook_secret]
      )
    rescue JSON::ParserError => e
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      return head :bad_request
    end

    handle_event(event)
    head :ok
  end

  private

  def handle_event(event)
    case event.type
    when 'customer.subscription.created'
      handle_subscription_created(event.data.object)
    when 'invoice.payment_succeeded'
      handle_invoice_paid(event.data.object)
    when 'customer.subscription.deleted'
      handle_subscription_deleted(event.data.object)
    else
      Rails.logger.info "Unhandled event type: #{event.type}"
    end
  end

  def handle_subscription_created(subscription)
    Subscription.create(stripe_id: subscription.id, state: 'unpaid')
    Rails.logger.info "Processed subscription creation: #{subscription.id}"
  end

  def handle_invoice_paid(invoice)
    subscription = Subscription.find_by(stripe_id: invoice.subscription)
    return unless subscription

    subscription.mark_as_paid if subscription

    Rails.logger.info "Updated subscription #{subscription.stripe_id} to paid state"
  end

  def handle_subscription_deleted(subscription)
    local_subscription = Subscription.find_by(stripe_id: subscription.id)

    unless local_subscription
      create_stripe_subscription(subscription)
      return
    end

    if local_subscription.state == 'unpaid'
      Rails.logger.info "only paid  can be canceled, subscription: #{subscription.id}"

      create_stripe_subscription(subscription)

      return
    end

    local_subscription.cancel
    Rails.logger.info "Canceled subscription: #{subscription.id}"
  end

  def create_stripe_subscription(subscription)
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    begin
      stripe_subscription = Stripe::Subscription.create({
        customer: subscription.customer,
        items: [{price: subscription.items.data[0].price.id}],
      })
      Rails.logger.info "Stripe subscription created successfully: #{stripe_subscription.id}"
    rescue Stripe::StripeError => e
      Rails.logger.error "Stripe API error: #{e.message}"
    end
  end
end
