require "test_helper"

class GlobalSearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get global_search_index_url
    assert_response :success
  end
end
