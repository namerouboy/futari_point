require "test_helper"

class PointCardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get point_cards_index_url
    assert_response :success
  end

  test "should get new" do
    get point_cards_new_url
    assert_response :success
  end

  test "should get show" do
    get point_cards_show_url
    assert_response :success
  end

  test "should get settings" do
    get point_cards_settings_url
    assert_response :success
  end
end
