module ConfigTestHelper
  def group_with(name:, **hash)
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
