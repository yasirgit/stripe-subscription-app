require 'rails_helper'
require 'stripe_mock'

RSpec.describe WebhooksController, type: :controller do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "POST #create" do
    let(:event) { StripeMock.mock_webhook_event(event_type) }

    before do
      allow(Stripe::Webhook).to receive(:construct_event).and_return(event)
    end

    context "when receiving a customer.subscription.created event" do
      let(:event_type) { 'customer.subscription.created' }

      it "creates a new unpaid subscription" do
        expect {
          post :create, body: event.to_json
        }.to change(Subscription, :count).by(1)

        expect(Subscription.last.state).to eq('unpaid')
        expect(response).to have_http_status(:ok)
      end
    end

    context "when receiving an invoice.payment_succeeded event" do
        let(:event_type) { 'invoice.payment_succeeded' }
        let(:subscription_id) { 'sub_00000000000000' }
        let!(:subscription) { create(:subscription, stripe_id: subscription_id, state: 'unpaid') }
        let(:invoice) { Stripe::Invoice.construct_from({ id: 'in_00000000000000', subscription: subscription_id }) }

        it "marks the subscription as paid" do
            controller.send(:handle_invoice_paid, invoice)

            subscription.reload
            expect(subscription.state).to eq('paid')
        end
    end

    context "when receiving a customer.subscription.deleted event" do
      let(:event_type) { 'customer.subscription.deleted' }
      let!(:subscription) { create(:subscription, stripe_id: event.data.object.id, state: 'paid') }

      it "cancels the subscription" do
        post :create, body: event.to_json

        subscription.reload
        expect(subscription.state).to eq('canceled')
        expect(response).to have_http_status(:ok)
      end
    end
  end
end