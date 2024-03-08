module Matchmaking
  class InvalidMatchmakingConfig < StandardError
    attr_accessor :field

    def initialize(field, message)
      @field = field
      super(message)
    end
  end

  class Config
    def initialize(config)
      @config = config

      validate!
    end

    def [](name)
      groups.find { |group| group.name == name.to_s }
    end

    def has_group?(name)
      @config.key?(name.intern)
    end

    def groups
      @config.map { |name, group_config|
        MatchmakingGroup.new.tap do |group|
          group.name = name.to_s
          group.slack_channel_name = group_config[:slack_channel]
          group.schedule = group_config[:schedule]

          group.is_active = group_config[:active_in] == "all" || group_config[:active_in].include?(Rails.env.to_s)

          if group_config[:target_size].is_a?(Hash)
            group.target_size = group_config[:target_size][:size]
            group.size_strategy = group_config[:target_size][:strategy]
          else
            group.target_size = group_config[:target_size]
          end

          group.accepted_decisions = group_config[:accepted_decisions]

          group.define_singleton_method(:readonly?) { true }
        end
      }
    end

    private

    def validate!
      @config.values.each { |group_config| validate_group(group_config) }
    end

    def validate_group(group_config)
      validate_active_in(group_config[:active_in])
      validate_schedule(group_config[:schedule])
      validate_target_size(group_config[:target_size])
      validate_accepted_decisions(group_config[:accepted_decisions])
    end

    def validate_active_in(active_in)
      return if active_in == "all" || active_in == "none"
      return if active_in.is_a?(Array) && active_in.all? { |env| env.is_a?(String) }

      raise InvalidMatchmakingConfig.new(:active_in, "must be 'all', 'none', or an array of environment strings")
    end

    def validate_schedule(schedule)
      return if %w[daily weekly fortnightly monthly].include?(schedule)

      raise InvalidMatchmakingConfig.new(:schedule, "must be 'daily', 'weekly', 'fortnightly', or 'monthly'")
    end

    def validate_target_size(target_size)
      return validate_target_size_integer(target_size) if target_size.is_a?(Integer)
      return validate_target_size_hash(target_size) if target_size.is_a?(Hash)

      raise InvalidMatchmakingConfig.new(:target_size, "must be an integer or a hash")
    end

    def validate_target_size_integer(target_size)
      return if target_size.positive?

      raise InvalidMatchmakingConfig.new(:target_size, "must be a positive integer")
    end

    def validate_target_size_hash(target_size)
      return if target_size[:size].is_a?(Integer) && %w[exact_size flexible_size].include?(target_size[:strategy])

      raise InvalidMatchmakingConfig.new(:target_size, "must be a hash with a size and a strategy of 'exact_size' or 'flexible_size'")
    end

    def validate_accepted_decisions(accepted_decisions)
      return if accepted_decisions.nil? || (accepted_decisions.is_a?(Array) && accepted_decisions.all? { |d| d.is_a?(String) })

      raise InvalidMatchmakingConfig.new(:accepted_decisions, "must be an array of strings")
    end
  end
end
