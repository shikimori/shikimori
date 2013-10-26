class CleanupOldNewsJob
  def perform
    AniMangaEntry.where(action: AnimeHistoryAction::Episode)
                 .where { created_at.lte(6.month.ago) }
                 .where { linked_id.not_in my{Anime.ongoing.map(&:id)} }
                 .destroy_all
  end
end
