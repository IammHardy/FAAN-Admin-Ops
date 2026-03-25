require "test_helper"

class Reports::LogReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reports_log_reports_index_url
    assert_response :success
  end
end
