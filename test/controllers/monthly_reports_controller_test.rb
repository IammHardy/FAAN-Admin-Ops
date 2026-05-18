require "test_helper"

class MonthlyReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get monthly_reports_index_url
    assert_response :success
  end

  test "should get show" do
    get monthly_reports_show_url
    assert_response :success
  end

  test "should get new" do
    get monthly_reports_new_url
    assert_response :success
  end

  test "should get create" do
    get monthly_reports_create_url
    assert_response :success
  end

  test "should get edit" do
    get monthly_reports_edit_url
    assert_response :success
  end

  test "should get update" do
    get monthly_reports_update_url
    assert_response :success
  end

  test "should get destroy" do
    get monthly_reports_destroy_url
    assert_response :success
  end
end
