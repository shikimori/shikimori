class MeasureChanges
  include HTMLDiff
  pattr_initialize :old_value, :new_value

  MINIMAL_CHANGES_PERCENT = 20

  def enough?
    new_text? || added_text? || changed_text? || false
  end

private

  def changed_text?
    insertions.size * 100.0 / old.size >= MINIMAL_CHANGES_PERCENT
  end

  def new_text?
    old.blank? && new.present?
  end

  def added_text?
    new.size * 100.0 / old.size >= MINIMAL_CHANGES_PERCENT + 100
  end

  def fix text
    (text || '').gsub(/\[.*?\]|[!@#$%^&*(),.\r\n\d—-]/, '').gsub(/\s\s+/, ' ')
  end

  def old
    @old ||= fix old_value
  end

  def new
    @new ||= fix new_value
  end

  def insertions
    @insertions ||= diff(old, new).scan(/<ins.*?>(.*?)<\/ins>/).flatten.join(' ')
  end
end
