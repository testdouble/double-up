module Notify
  class DeterminesRetriability
    def can_retry?(schedule, original_date:)
      return false unless weekday?(Date.today)

      case schedule.intern
      when :daily
        original_date == Date.today

      when :weekly
        (original_date + 4.days) > Date.today

      when :fortnightly
        (original_date + 8.days) > Date.today

      when :monthly
        (original_date + 16.days) > Date.today

      else
        false
      end
    end

    private

    def weekday?(date)
      date.wday > 0 && date.wday < 6
    end
  end
end
