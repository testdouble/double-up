class MatchmakingGroupsController < ApplicationController
  def index
    @groups = CollectGroups.new.call.to_h
      .reduce([]) { |acc, (k, v)| acc << v.to_h.merge(name: k) }
      .sort_by { |g| [g[:readonly] ? 0 : 1, g[:name]] }
  end

  def new
    @group = MatchmakingGroup.new
  end

  def create
    MatchmakingGroup.create(group_params.merge(slack_user_id: @current_user.slack_user_id))
    redirect_to matchmaking_groups_path
  end

  def edit
    @group = MatchmakingGroup.find_by(id: params[:id])
    redirect_to matchmaking_groups_path if @group.nil?
  end

  def update
    @group = MatchmakingGroup.find_by(id: params[:id])
    @group.update(group_params)
    redirect_to matchmaking_groups_path
  end

  def destroy
    @group = MatchmakingGroup.find_by(id: params[:id])
    @group.destroy if @group.present?
    redirect_to matchmaking_groups_path
  end

  private

  def group_params
    params.require(:matchmaking_group)
      .permit(:name, :slack_channel_name, :schedule, :target_size, :is_active)
  end
end
