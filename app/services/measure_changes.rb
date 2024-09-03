class MeasureChanges
  pattr_initialize :old_value, :new_value

  MINIMAL_CHANGES_PERCENT = 25
  BBCODE_CLEANUP = /
    \[ .*? \]
    |
    [!@#$%^&*(),.\r\n\d—-]
  /mix

  def enough?
    new_text? || added_text? || changed_text? || false
  end

  def text_change
    if new_text?
      100
    elsif old.empty?
      0
    else
      insertions.size * 100.0 / old.size
    end
  end

private

  def changed_text?
    text_change >= MINIMAL_CHANGES_PERCENT
  end

  def new_text?
    old.blank? && new.present?
  end

  def added_text?
    new.size * 100.0 / old.size >= MINIMAL_CHANGES_PERCENT + 100
  end

  def fix text
    (text || '')
      .gsub(/\[\[|\]\]/, '')
      .gsub(BBCODE_CLEANUP, '')
      .gsub(/\s\s+/, ' ')
  end

  def old
    @old ||= fix old_value
  end

  def new
    @new ||= fix new_value
  end

  def insertions
    @insertions ||=
      HTMLDiff.diff(old, new).scan(%r{<ins.*?>(.*?)</ins>}).flatten.join(' ')
  end
end
