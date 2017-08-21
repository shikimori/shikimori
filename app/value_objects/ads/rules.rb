class Ads::Rules
  prepend ActiveCacher.instance

  attr_accessor :shows
  instance_cache :shows_policy, :shows_this_day, :shows_per_week

  FAST = 'fast'
  SLOW = 'slow'

  INTERVALS = {
    SLOW => [
      0.seconds, 2.minutes, 4.minutes, 8.minutes, 16.minutes, 32.minutes
    ],
    FAST => [
      0.seconds, 30.seconds, 2.minutes, 4.minutes
    ]
  }

  def initialize rules, shows_cookie
    @day_ago = 1.day.ago
    @week_ago = 1.week.ago

    @rules = rules
    @shows = parse shows_cookie
  end

  def show?
    @shows.size < shows_per_week &&
      shows_this_day.size < shows_per_day &&
      !shown_recently?
  end

  def fast_shows?
    shows_policy == FAST
  end

  def shows_policy
    if shows_ratio >= period_ratio
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

private

  def parse shows_cookie
    return [] if shows_cookie.blank?

    shows_cookie
      .split('|')
      .map { |v| Time.zone.at v.to_i }
      .select { |v| v > @week_ago }
      .sort
  end

  def shown_recently?
    # return false if shows_this_hour.blank?

    # ap next_show_in
    false
  end

  def shows_ratio
    (shows.size * 1.0 / shows_per_week).round(2)
  end

  def period_ratio
    ((Time.zone.now - (@shows.first || Time.zone.now)) / 1.week).round(2)
  end

  def shows_this_day
    @shows.select { |v| v > @day_ago }
  end

  def shows_per_day
    if fast_shows?
      (shows_per_week.to_f / 3.5).ceil
    else
      (shows_per_week.to_f / 7).ceil
    end
  end

  def shows_per_week
    @rules[:shows_per_week]
  end
end
