require "test_helper"

class MinutesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get minutes_index_url
    assert_response :success
  end

  test "should get show" do
    get minutes_show_url
    assert_response :success
  end

  test "should get new" do
    get minutes_new_url
    assert_response :success
  end

  test "should get create" do
    get minutes_create_url
    assert_response :success
  end
end
