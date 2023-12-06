class CollectsGroups
  def initialize(config: nil)
    @config = config || Rails.application.config.x.matchmaking
  end

  def call
    extra_groups = MatchmakingGroup.all.reduce({}) do |acc, group|
      acc.merge(group.name.intern => OpenStruct.new({
        id: group.id,
        active: group.is_active,
        size: group.target_size,
        channel: group.slack_channel_name,
        schedule: group.schedule.intern,
        readonly: false
      }))
    end

    OpenStruct.new(yaml_config_with_readonly.merge(extra_groups))
  end

  private

  def yaml_config_with_readonly
    @config.to_h.transform_values do |v|
      OpenStruct.new(v.to_h.merge(readonly: true))
    end
  end
end
