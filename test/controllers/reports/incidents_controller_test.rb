require "test_helper"

class Reports::IncidentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reports_incidents_index_url
    assert_response :success
  end
end
