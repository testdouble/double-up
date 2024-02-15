class MatchmakingGroupsController < ApplicationController
  def index
    @groups = CollectGroups.new.call.sort_by { |group| [group.readonly? ? 0 : 1, group.name] }
  end

  def new
    @group = MatchmakingGroup.new
  end

  def create
    if MatchmakingGroup.name_exists?(group_params[:name])
      flash[:error] = "Group already exists"
    else
      MatchmakingGroup.create(group_params.merge(slack_user_id: @current_user.slack_user_id))
      flash[:notice] = "Group created"
    end

    redirect_to matchmaking_groups_path
  end

  def edit
    @group = MatchmakingGroup.find_by(id: params[:id])
    redirect_to matchmaking_groups_path if @group.nil?
  end

  def update
    @group = MatchmakingGroup.find_by(id: params[:id])

    if @group.name != group_params[:name] && MatchmakingGroup.name_exists?(group_params[:name])
      flash[:error] = "Other group already exists with that name"
    else
      @group = MatchmakingGroup.find_by(id: params[:id])
      @group.update(group_params)

      flash[:notice] = "Group updated"
    end
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
