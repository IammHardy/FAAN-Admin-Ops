require "test_helper"

class OperationStaffsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get operation_staffs_index_url
    assert_response :success
  end

  test "should get show" do
    get operation_staffs_show_url
    assert_response :success
  end

  test "should get new" do
    get operation_staffs_new_url
    assert_response :success
  end

  test "should get create" do
    get operation_staffs_create_url
    assert_response :success
  end

  test "should get edit" do
    get operation_staffs_edit_url
    assert_response :success
  end

  test "should get update" do
    get operation_staffs_update_url
    assert_response :success
  end

  test "should get destroy" do
    get operation_staffs_destroy_url
    assert_response :success
  end
end
