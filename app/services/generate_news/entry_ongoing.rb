class GenerateNews::EntryOngoing < GenerateNews::EntryAnons
private

  def action
    AnimeHistoryAction::Ongoing
  end
end
