class UserHistoryQuery
  pattr_initialize :user

  def postload page, limit
    history = fetch page, limit
    add_postloader = history.size > limit

    collection = history.take(limit).map(&:decorate)

    [group(collection), add_postloader]
  end

  def date_interval updated_at
    if 3.years.ago > updated_at then :many_years
    elsif 2.years.ago > updated_at then :two_years
    elsif 1.year.ago > updated_at then :year
    elsif 6.months.ago > updated_at then :half_year
    elsif 5.months.ago > updated_at then :five_months
    elsif 4.months.ago > updated_at then :four_months
    elsif 3.months.ago > updated_at then :three_months
    elsif 2.months.ago > updated_at then :two_months
    elsif 1.month.ago > updated_at then :month
    elsif 3.weeks.ago > updated_at then :three_weeks
    elsif 2.weeks.ago > updated_at then :two_weeks
    elsif 1.week.ago > updated_at then :week
    elsif 2.days.ago.end_of_day > updated_at then :during_week
    elsif Time.zone.today.beginning_of_day > updated_at then :yesterday
    else
      :today
    end
  end

private

  def fetch page, limit
    user.all_history
      .includes(:anime, :manga)
      .offset(limit * (page - 1))
      .limit(limit + 1)
      .to_a
  end

  def group collection
    collection.group_by do |entry|
      date_interval entry.updated_at.to_datetime
    end
  end
end
