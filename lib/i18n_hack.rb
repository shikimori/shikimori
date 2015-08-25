require 'i18n'

module I18n
  LOCALES = {
    'russian' => :ru,
    'english' => :en
  }

  def self.russian?
    I18n.locale == :ru
  end

  def self.time_part count, part
    "%s %s" % [count, Russian.p(count, *t("datetime.parts.#{part}").values)]
  end

  def self.spent_time time, is_genitive
    if time.days.zero?
      '0 часов'

    elsif time.years >= 1
      months = time.months_part > 0 ? " и #{I18n.time_part(time.months_part.to_i, :month)}" : ''
      I18n.time_part(time.years.to_i, :year) + months

    elsif time.months >= 1
      weeks = time.weeks_part > 0 ?
        " и #{I18n.time_part(time.weeks_part.to_i, :week)}" : ''
      weeks.sub! '1 неделя', '1 неделю' if is_genitive
      I18n.time_part(time.months.to_i, :month) + weeks

    elsif time.weeks >= 1
      days = time.days_part > 0 ? " и #{I18n.time_part(time.days_part.to_i, :day)}" : ''
      I18n.time_part(time.weeks.to_i, :week) + days

    elsif time.days >= 1
      hours = time.hours_part > 0 ? " и #{I18n.time_part(time.hours_part.to_i, :hour)}" : ''
      I18n.time_part(time.days.to_i, :day) + hours

    elsif time.hours >= 1
      minutes = time.minutes_part > 0 ?
        " и #{I18n.time_part(time.minutes_part.to_i, :minute)}" : ''
      minutes.sub! '1 неделя', '1 неделю' if is_genitive

      I18n.time_part(time.hours.to_i, :hour) + minutes

    elsif time.minutes >= 1
      I18n.time_part(time.minutes.to_i, :minute)
    end
  end
end
