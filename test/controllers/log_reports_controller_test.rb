require "test_helper"

class LogReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get log_reports_index_url
    assert_response :success
  end

  test "should get show" do
    get log_reports_show_url
    assert_response :success
  end

  test "should get new" do
    get log_reports_new_url
    assert_response :success
  end

  test "should get create" do
    get log_reports_create_url
    assert_response :success
  end

  test "should get edit" do
    get log_reports_edit_url
    assert_response :success
  end

  test "should get update" do
    get log_reports_update_url
    assert_response :success
  end

  test "should get destroy" do
    get log_reports_destroy_url
    assert_response :success
  end

  test "should get submit_report" do
    get log_reports_submit_report_url
    assert_response :success
  end

  test "should get review" do
    get log_reports_review_url
    assert_response :success
  end

  test "should get print" do
    get log_reports_print_url
    assert_response :success
  end
end
