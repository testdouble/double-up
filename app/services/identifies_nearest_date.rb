class IdentifiesNearestDate
  def call(schedule, from: Date.today)
    case schedule.intern
    when :daily
      next_weekday(from)
    when :weekly
      next_monday(from)
    when :fortnightly
      next_odd_monday(from)
    when :monthly
      next_first_monday(from)
    else
      raise ArgumentError.new("No matching schedule for '#{schedule}'")
    end
  end

  private

  def next_monday(date)
    return date if date.monday?

    next_monday(date + 1)
  end

  def next_weekday(date)
    return date if date.on_weekday?

    next_weekday(date + 1)
  end

  def next_odd_monday(date)
    next_date = next_monday(date)

    return next_date if next_date.cweek.odd?

    next_monday(next_date + 1)
  end

  def next_first_monday(date)
    first_monday_of_month = next_monday(date.beginning_of_month)

    return date if date == first_monday_of_month
    return first_monday_of_month if date < first_monday_of_month

    next_monday(date.beginning_of_month + 1.month)
  end
end
