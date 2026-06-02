require "test_helper"

class DutyRostersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get duty_rosters_index_url
    assert_response :success
  end

  test "should get new" do
    get duty_rosters_new_url
    assert_response :success
  end

  test "should get create" do
    get duty_rosters_create_url
    assert_response :success
  end

  test "should get edit" do
    get duty_rosters_edit_url
    assert_response :success
  end

  test "should get update" do
    get duty_rosters_update_url
    assert_response :success
  end

  test "should get destroy" do
    get duty_rosters_destroy_url
    assert_response :success
  end
end
