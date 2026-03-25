require "test_helper"

class Reports::DispatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reports_dispatches_index_url
    assert_response :success
  end
end
