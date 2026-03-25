require "test_helper"

class LogEntriesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get log_entries_create_url
    assert_response :success
  end

  test "should get edit" do
    get log_entries_edit_url
    assert_response :success
  end

  test "should get update" do
    get log_entries_update_url
    assert_response :success
  end

  test "should get destroy" do
    get log_entries_destroy_url
    assert_response :success
  end
end
