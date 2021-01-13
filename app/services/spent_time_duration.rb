class SpentTimeDuration
  pattr_initialize :user_rate

  MAXIMUM_REWATCHES = 50

  def anime_hours entry_episodes, episode_duration
    rewatched_hours = rewatches_count * entry_episodes * episode_duration
    watched_hours = @user_rate.episodes * episode_duration

    rewatched_hours + watched_hours
  end

  def manga_hours entry_chapters, entry_volumes
    rewatched_chapters_hours =
      rewatches_count * entry_chapters * chapter_duration
    rewatched_volumes_hours =
      rewatches_count * entry_volumes * volume_duration

    rewatched_hours = [rewatched_chapters_hours, rewatched_volumes_hours].max

    rewatched_hours + [
      manga_read_chapters_hours,
      manga_read_volumes_hours
    ].max
  end

private

  def manga_read_chapters_hours
    @user_rate.chapters * chapter_duration
  end

  def manga_read_volumes_hours
    @user_rate.volumes * volume_duration
  end

  def rewatches_count
    @user_rate.rewatches >= MAXIMUM_REWATCHES ? 0 : @user_rate.rewatches
  end

  def chapter_duration
    entry_klass::CHAPTER_DURATION
  end

  def volume_duration
    entry_klass::VOLUME_DURATION
  end

  def entry_klass
    if @user_rate.is_a? UserRates::StructEntry
      @user_rate.target_class_downcased == 'ranobe' ? Ranobe : Manga

    elsif @user_rate.is_a? ExtendedUserRate
      @user_rate.type == Ranobe.name ? Ranobe : Manga

    else
      @user_rate.manga.is_a?(Ranobe) ? Ranobe : Manga
    end
  end
end
