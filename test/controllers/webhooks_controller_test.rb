require "test_helper"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get webhooks_create_url
    assert_response :success
  end
end
