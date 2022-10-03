class BroadcastDate
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
  DATE = /
    (?<day> #{DAYS.join '|'} ) \s
    at \s
    (?<hours> \d{2} ) : (?<minutes> \d{2} ) \s
    \(JST\)
  /mix
  JST_OFFSET = - 6.hours

  def self.parse schedule, start_on
    new(schedule, [start_on, Time.zone.today].compact.max).to_datetime
  end

  def to_datetime
    return unless @schedule && @schedule =~ DATE

    @start_on.beginning_of_week +
      DAYS.index($LAST_MATCH_INFO[:day]).days +
      $LAST_MATCH_INFO[:hours].to_i.hours +
      $LAST_MATCH_INFO[:minutes].to_i.minutes +
      JST_OFFSET
  end
end
