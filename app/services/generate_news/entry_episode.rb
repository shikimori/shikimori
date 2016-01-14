class GenerateNews::EntryEpisode < GenerateNews::EntryAnons
  pattr_initialize :entry, :aired_at

  def action
    AnimeHistoryAction::Episode
  end

  def value
    @entry.episodes_aired.to_s
  end

  def created_at
    @aired_at
  end
end
