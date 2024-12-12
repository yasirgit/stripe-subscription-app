require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    post '/webhooks', params: { body: '{}' }
    assert_response :success
  end
end
