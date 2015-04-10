class SpentTimeDuration
  pattr_initialize :user_rate

  MAXIMUM_REWATCHES = 9

  def anime_hours entry_episodes, episode_duration
    rewatched_hours = rewatches_count * entry_episodes * episode_duration
    watched_hours = @user_rate.episodes * episode_duration

    rewatched_hours + watched_hours
  end

  def manga_hours entry_chapters, entry_volumes
    rewatched_chapters_hours = rewatches_count * entry_chapters * Manga::CHAPTER_DURATION
    rewatched_volumes_hours = rewatches_count * entry_volumes * Manga::VOLUME_DURATION
    rewatched_hours = [rewatched_chapters_hours, rewatched_volumes_hours].max

    rewatched_hours + [
      manga_chapters_hours(entry_chapters),
      manga_volumes_hours(entry_chapters)
    ].max
  end

private
  def manga_chapters_hours entry_chapters
    @user_rate.chapters * Manga::CHAPTER_DURATION
  end

  def manga_volumes_hours entry_chapters
    @user_rate.volumes * Manga::VOLUME_DURATION
  end

  def rewatches_count
    @user_rate.rewatches >= MAXIMUM_REWATCHES ? 0 : @user_rate.rewatches
  end
end
