class Schedule
  pattr_initialize :schedule, :start_on

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

  def self.parse schedule, start_on
    new(schedule, start_on || Time.zone.today).to_datetime
  end

  def to_datetime
    return unless schedule && schedule =~ DATE

    start_on.beginning_of_week +
      DAYS.index($~[:day]).days +
      $~[:hours].to_i.hours +
      $~[:minutes].to_i.minutes +
      JST_OFFSET
  end
end
