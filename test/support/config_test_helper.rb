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
      block.call(config)
    end
  end
end
