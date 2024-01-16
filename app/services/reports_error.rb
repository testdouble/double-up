class ReportsError
  # Will also work if you pass a string
  def self.report(error)
    Rails.logger.error(error.to_s)
    if Rails.env.production?
      Bugsnag.notify(error)
    else
      raise error
    end
  end
end
