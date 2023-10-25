class CollectsGroups
  def initialize(config: nil)
    @config = config || Rails.application.config.x.matchmaking
  end

  def call
    extra_groups = MatchmakingGroup.all.reduce({}) do |acc, group|
      acc.merge(group.name.intern => OpenStruct.new({
        active: group.is_active,
        size: group.target_size,
        channel: group.slack_channel_name,
        schedule: group.schedule.intern,
        readonly: false
      }))
    end

    OpenStruct.new(@config.to_h.merge(extra_groups))
  end
end
