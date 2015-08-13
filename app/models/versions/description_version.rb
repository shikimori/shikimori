class Versions::DescriptionVersion < Version
  include HTMLDiff

  def fix_state
    old = fix item_diff['description'][0]
    new = fix item_diff['description'][1]

    fair_state = old.blank? || much_bigger?(old, new)

    update state: fair_state
  end

private

  def much_bigger? old, new
    new.size * 1.0 / old.size > 1.2
  end

  def fix text
    (text || '').gsub(/\[.*?\]|[!@#$%^&*(),.\r\n\d—-]/, '').gsub(/\s\s+/, ' ')
  end
end
