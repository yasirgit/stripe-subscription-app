require "test_helper"
require "openssl"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    payload = { id: 'evt_test_webhook', type: 'customer.subscription.created' }.to_json
    timestamp = Time.now.to_i
    secret = Rails.configuration.stripe[:webhook_secret]
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, "#{timestamp}.#{payload}")
    headers = {
      'HTTP_STRIPE_SIGNATURE' => "t=#{timestamp},v1=#{signature}"
    }

    post '/webhooks', params: payload, headers: headers
    assert_response :success
  end
end