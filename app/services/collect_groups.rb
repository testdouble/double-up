class CollectGroups
  def initialize(config: nil)
    @config = config || Rails.application.config.x.matchmaking
  end

  def call
    extra_groups = MatchmakingGroup.all
    readonly_groups + extra_groups
  end

  private

  def readonly_groups
    @config.to_h.map do |name, group_config|
      normalized = group_config.to_h.transform_keys do |key|
        next :target_size if key.intern == :size
        next :is_active if key.intern == :active
        next :slack_channel_name if key.intern == :channel
        key
      end

      group = MatchmakingGroup.new(normalized.merge(name: name))
      group.define_singleton_method(:readonly?) { true }
      group
    end
  end
end
