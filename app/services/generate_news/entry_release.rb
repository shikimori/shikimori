class GenerateNews::EntryRelease < GenerateNews::EntryAnons
private

  def action
    AnimeHistoryAction::Released
  end

  def is_processed
    !!(entry.released_on && entry.released_on + 2.weeks < Time.zone.now)
  end

  def created_at
    is_processed ? entry.released_on.to_datetime : Time.zone.now
  end
end
