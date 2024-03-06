module ConfigTestHelper
  def group_with(name:, **hash)
    group_defaults = {
      target_size: 2,
      is_active: true,
      schedule: :weekly,
      slack_channel_name: "test-channel"
    }
    attrs = hash.reverse_merge(group_defaults).merge(name: name)
    MatchmakingGroup.new(attrs).tap do |group|
      group.define_singleton_method(:readonly?) { true }
    end
  end

  def stub_matchmaking_config(groups, &block)
    config = Mocktail.of(Matchmaking::Config)
    Rails.application.config.x.stub :matchmaking, config do
      stubs { config.groups }.with { groups }
      block.call
    end
  end

  def matchmaking_config_of(hash = {})
    group_defaults = {size: 2, active: true, schedule: :weekly, channel: "test-channel"}

    normalized = hash.map do |group, group_config|
      [group, OpenStruct.new(group_config.reverse_merge(group_defaults).slice(:size, :active, :schedule, :channel))]
    end.to_h

    Rails.application.config.x.stub :matchmaking, OpenStruct.new(normalized) do
      yield if block_given?
    end
  end
end
