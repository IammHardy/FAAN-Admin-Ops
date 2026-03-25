require "test_helper"

class Reports::SummariesControllerTest < ActionDispatch::IntegrationTest
  test "should get daily" do
    get reports_summaries_daily_url
    assert_response :success
  end

  test "should get monthly" do
    get reports_summaries_monthly_url
    assert_response :success
  end
end
