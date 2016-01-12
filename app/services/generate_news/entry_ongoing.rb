class GenerateNews::EntryOngoing < GenerateNews::EntryAnons
  def action
    AnimeHistoryAction::Ongoing
  end
end
