class SpentTime
  vattr_initialize :days

  def years
    days / 365
  end

  def years_part
    years.to_i
  end

  def months_6
    days / 180
  end

  def months_6_part
    [
      years > 0 ? 1 : 0,
      ((days % 365) / 180).to_i
    ].max
  end

  def months_3
    days / 90
  end

  def months_3_part
    [
      months_6 > 0 ? 1 : 0,
      ((days % 365 % 180) / 90).to_i
    ].max
  end

  def months
    days / 30
  end

  def months_part
    [
      months_3 > 0 ? 1 : 0,
      ((days % 365 % 90) / 30).to_i
    ].max
  end

  def weeks
    days / 7
  end

  def weeks_part
    [
      months > 0 ? 1 : 0,
      ((days % 365 % 30) / 7).to_i
    ].max
  end

  def days_part
    [
      weeks > 0 ? 1 : 0,
      (days % 365 % 30 % 7).to_i
    ].max
  end

  def hours
    days * 24.0
  end

  def hours_part
    [
      days > 0 ? 1 : 0,
      ((days - days.to_i) * 24).round(3).to_i
    ].max
  end

  def minutes
    hours * 60.0
  end

  def equal? rhs
    days == rhs.days
  end
end
