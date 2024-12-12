require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    post webhooks_create_url
    assert_response :success
  end
end
