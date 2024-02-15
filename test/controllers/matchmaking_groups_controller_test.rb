require "test_helper"

class MatchmakingGroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @matchmaking_group = create_matchmaking_group(name: "test")
    @user = create_user

    sign_in_as(@user)
  end

  test "should get index" do
    get matchmaking_groups_url
    assert_response :success
  end

  test "should get new" do
    get new_matchmaking_group_url
    assert_response :success
  end

  test "should create matchmaking_group" do
    assert_difference("MatchmakingGroup.count") do
      post matchmaking_groups_url, params: {
        matchmaking_group: {name: "New Group", slack_channel_name: "test-channel", schedule: "daily", target_size: 2, is_active: true}
      }
    end

    assert_redirected_to matchmaking_groups_url
  end

  test "should get edit" do
    get edit_matchmaking_group_url(@matchmaking_group)
    assert_response :success
  end

  test "should update matchmaking_group" do
    patch matchmaking_group_url(@matchmaking_group), params: {matchmaking_group: {name: "Updated Group"}}
    assert_redirected_to matchmaking_groups_url
  end

  test "should destroy matchmaking_group" do
    assert_difference("MatchmakingGroup.count", -1) do
      delete matchmaking_group_url(@matchmaking_group)
    end

    assert_redirected_to matchmaking_groups_url
  end
end
