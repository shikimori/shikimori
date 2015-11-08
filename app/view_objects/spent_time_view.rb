class SpentTimeView
  include Translation

  pattr_initialize :spent_time

  def text
    if spent_time.days.zero?
      part_text spent_time.days, :hour

    elsif spent_time.years >= 1
      parts_text :year, :month

    elsif spent_time.months >= 1
      parts_text :month, :week

    elsif spent_time.weeks >= 1
      parts_text :week, :day

    elsif spent_time.days >= 1
      parts_text :day, :hour

    elsif spent_time.hours >= 1
      parts_text :hour, :minute

    elsif spent_time.minutes >= 1
      part_text spent_time.minutes, :minute
    end
  end

private

  def parts_text part_1, part_2
    part_1_spent_time = spent_time.send "#{part_1.to_s.pluralize}_part"
    part_2_spent_time = spent_time.send "#{part_2.to_s.pluralize}_part"

    text = []
    text << part_text(part_1_spent_time, part_1)
    if part_2_spent_time > 0
      text << part_text(part_2_spent_time, part_2)
    end
    text.to_sentence
  end

  def part_text count, part
    format '%s %s', count.to_i, i18n_i("datetime.#{part}", count.to_i)
  end
end
