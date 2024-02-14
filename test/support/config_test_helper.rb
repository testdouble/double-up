module ConfigTestHelper
  def build_config(hash = {})
    raise ArgumentError, "arg must be a Hash" unless hash.is_a?(Hash)

    group_defaults = {size: 2, active: true, schedule: :weekly, channel: "test-channel"}

    normalized = hash.map do |group, group_config|
      [group, OpenStruct.new(group_config.reverse_merge(group_defaults).slice(:size, :active, :schedule, :channel))]
    end.to_h

    OpenStruct.new(normalized)
  end

  def group_with(name:, **hash)
    raise ArgumentError, "arg must be a Hash" unless hash.is_a?(Hash)

    normalized = hash.transform_keys do |key|
      next :target_size if key.intern == :size
      next :is_active if key.intern == :active
      next :slack_channel_name if key.intern == :channel
      key
    end
    group_defaults = {target_size: 2, is_active: true, schedule: :weekly, slack_channel_name: "test-channel"}

    MatchmakingGroup.new(normalized.reverse_merge(group_defaults).merge(name: name))
  end
end
