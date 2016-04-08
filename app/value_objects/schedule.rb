class Schedule
  pattr_initialize :schedule

  DAYS = %w(
    Mondays
    Tuesdays
    Wednesdays
    Thursdays
    Fridays
    Saturdays
    Sundays
  )
  DATE = %r(
    (?<day> #{DAYS.join '|'} ) \s
    at \s
    (?<hours> \d{2} ) : (?<minutes> \d{2} ) \s
    \(JST\)
  )mix
  JST_OFFSET = - 6.hours

  def self.parse schedule
    new(schedule).to_datetime
  end

  def to_datetime
    return unless schedule && schedule =~ DATE

    Time.zone.now.beginning_of_week +
      DAYS.index($~[:day]).days +
      $~[:hours].to_i.hours +
      $~[:minutes].to_i.minutes +
      JST_OFFSET
  end
end
