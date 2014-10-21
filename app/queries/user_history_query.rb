class UserHistoryQuery
  pattr_initialize :user

  def postload page, limit
    history = fetch page, limit
    add_postloader = history.size > limit

    collection = history.take(limit).map(&:decorate)

    [group(collection), add_postloader]
  end

private
  def fetch page, limit
    user.all_history
      .offset(limit * (page-1))
      .limit(limit + 1)
      .to_a
  end

  def group collection
    today = Time.zone.today.beginning_of_day

    collection.group_by do |entry|
      date_interval entry.updated_at.to_datetime, today
    end
  end

  def date_interval updated_at, today
    if today < updated_at then :today
    elsif today - 1.day < updated_at then :yesterday
    elsif today - 1.week < updated_at then :week
    elsif today - 2.weeks < updated_at then :two_weeks
    elsif today - 3.weeks < updated_at then :three_weeks
    elsif today - 4.weeks < updated_at then :four_weeks
    elsif today - 2.months < updated_at then :month
    elsif today - 3.months < updated_at then :two_months
    elsif today - 4.months < updated_at then :three_months
    elsif today - 5.months < updated_at then :four_months
    elsif today - 6.months < updated_at then :five_months
    elsif today - 9.months < updated_at then :half_year
    elsif today - 1.year < updated_at then :year
    elsif today - 2.year < updated_at then :two_years
    else :many_years
    end
  end
end
