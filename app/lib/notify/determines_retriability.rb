module Notify
  class DeterminesRetriability
    def call(schedule, original_date:)
      return :noretry unless weekday?(Date.today)

      case schedule.intern
      when :daily
        retriability_for { original_date == Date.today }

      when :weekly
        retriability_for { (original_date + 4.days) > Date.today }

      when :fortnightly
        retriability_for { (original_date + 8.days) > Date.today }

      when :monthly
        retriability_for { (original_date + 16.days) > Date.today }

      else
        raise ArgumentError.new("Unable to determine remaining retries for '#{schedule}'")
      end
    end

    private

    def weekday?(date)
      date.wday > 0 && date.wday < 6
    end

    def retriability_for
      yield ? :retry : :noretry
    end
  end
end
