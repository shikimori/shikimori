class Ads::Rules
  prepend ActiveCacher.instance

  attr_reader :shows
  instance_cache :shows_policy, :shows_this_day, :shows_this_week

  VERY_FAST = 'very_fast'
  FAST = 'fast'
  SLOW = 'slow'

  INTERVALS = {
    SLOW => [
      0.seconds, 30.seconds, 2.minutes, 4.minutes, 8.minutes, 16.minutes
    ],
    FAST => [
      0.seconds, 30.seconds, 2.minutes, 3.minutes
    ],
    VERY_FAST => [
      0.seconds, 5.seconds, 10.seconds
    ]
  }
  DAY_INTERVAL = 12.hours
  WEEK_INTERVAL = 1.week

  DELIMITER = 'x'

  def initialize rules, shows_cookie
    @now = Time.zone.now
    @day_ago = DAY_INTERVAL.ago
    @week_ago = WEEK_INTERVAL.ago

    @rules = rules
    @shows = parse shows_cookie
  end

  def show?
    @shows.size < shows_per_week &&
      shows_this_day.size < shows_per_day &&
      next_show_ready?
  end

  def export_shows
    (shows + [@now]).map(&:to_i).join(DELIMITER)
  end

private

  def parse shows_cookie
    return [] if shows_cookie.blank?

    shows_cookie
      .split(DELIMITER)
      .map { |v| Time.zone.at v.to_i }
      .select { |v| v > @week_ago }
      .sort
  end

  def fast_shows?
    shows_policy == FAST
  end

  def shows_policy
    if slow_shows_per_day - shows_this_day.size > INTERVALS[SLOW].size * 2
      VERY_FAST
    elsif shows_ratio >= period_ratio
      SLOW
    else
      FAST
    end
  end

  def next_show_in
    INTERVALS[shows_policy][shows_this_day.size] ||
      INTERVALS[shows_policy].last
  end

  def next_show_at
    (shows_this_day.last || 1.minute.ago) + next_show_in
  end

  def next_show_ready?
    next_show_at <= @now
  end

  def shows_ratio
    (shows.size * 1.0 / shows_per_week).round(2)
  end

  def period_ratio
    ((@now - (@shows.first || @now)) / 1.week).round(2)
  end

  def shows_this_day
    @shows_this_day ||= @shows.select { |v| v > @day_ago }
  end

  def shows_per_day
    if fast_shows?
      (shows_per_week.to_f / 3.5).ceil
    else
      slow_shows_per_day
    end
  end

  def slow_shows_per_day
    (shows_per_week.to_f / 7).ceil
  end

  def shows_per_week
    @rules[:shows_per_week]
  end
end
