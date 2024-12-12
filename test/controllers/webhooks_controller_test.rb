require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    payload = { id: 'evt_test_webhook', type: 'customer.subscription.created' }.to_json
    headers = {
      'HTTP_STRIPE_SIGNATURE' => Stripe::Webhook::Signature.compute_signature_header(
        Time.now.to_i, payload, Rails.configuration.stripe[:webhook_secret]
      )
    }

    post '/webhooks', params: payload, headers: headers
    assert_response :success
  end
end
