require "test_helper"

class DutySessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get duty_sessions_new_url
    assert_response :success
  end

  test "should get create" do
    get duty_sessions_create_url
    assert_response :success
  end

  test "should get end_current" do
    get duty_sessions_end_current_url
    assert_response :success
  end
end
