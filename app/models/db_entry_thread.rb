class DbEntryThread < Topic
  FORUM_IDS = {
    'Anime' => 1,
    'Manga' => 1,
    'Character' => 1,
    'Person' => 1,
    'Club' => Forum::CLUBS_ID,
    'Review' => 12,
    'Contest' => Forum::CONTESTS_ID,
    'CosplayGallery' => Forum::COSPLAY_ID
  }

  attr_defaults forum_id: -> { FORUM_IDS[linked_type] }
  attr_defaults user_id: -> { BotsService.get_poster.id }

  before_save :sync

  # связанное с новостью аниме
  def anime
    raise "linked Anime requested but it is Manga" if linked_type == Manga.name
    linked
  end

  # связанное с новостью аниме
  def manga
    raise "linked Manga requested but it is Anime" if linked_type == Anime.name
    linked
  end

  # название
  def title
    self[:title] ? self[:title].html_safe : nil
  end

private

  def sync
  end
end
