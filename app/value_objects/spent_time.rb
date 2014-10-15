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

  #def months_6_part
    #((days % 365) / 180).to_i
  #end

  def months_3
    days / 90
  end

  #def months_3_part
    #((days % 365 % 180) / 90).to_i
  #end

  def months
    days / 30
  end

  #def months_part
    #((days % 365 % 90) / 30).to_i
  #end

  def months_part
    ((days % 365) / 30).to_i
  end

  def weeks
    days / 7
  end

  def weeks_part
    ((days % 365 % 30) / 7).to_i
  end

  def days_part
    (days % 365 % 30 % 7).to_i
  end

  def hours
    days * 24.0
  end

  def hours_part
    ((days - days.to_i) * 24).round(3).to_i
  end

  def minutes
    hours * 60.0
  end

  def minutes_part
    (((days - days.to_i) * 24 * 60) % 60).round(3).to_i
  end

  def equal? rhs
    days == rhs.days
  end
end
