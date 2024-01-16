module ConfigTestHelper
  def matchmaking_config(hash = {})
    raise ArgumentError, "arg must be a Hash" unless hash.is_a?(Hash)

    group_defaults = {size: 2, active: true, schedule: :weekly, channel: "test-channel"}

    normalized = hash.map do |group, group_config|
      [group, OpenStruct.new(group_config.reverse_merge(group_defaults).slice(:size, :active, :schedule, :channel))]
    end.to_h

    OpenStruct.new(normalized)
  end
end
