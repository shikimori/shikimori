class DbEntryThread < Topic
  SectionIDs = {
    'Anime' => 1,
    'Manga' => 6,
    'Character' => 7,
    'Person' => 14,
    'Group' => Section::GROUPS_ID,
    'Review' => 12,
    'Contest' => Section::CONTESTS_ID,
    'CosplayGallery' => Section::COSPLAY_ID
  }

  attr_defaults section_id: -> { SectionIDs[linked_type] }
  attr_defaults user_id: -> { BotsService.get_poster.id }

  before_save :sync

  validates :title, presence: true, unless: :generated?
  validates :text, presence: true, unless: :generated?

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

  # раздел топика
  def section
    if news? && action != 'episode'
      Section::static[:news]
    else
      super
    end
  end

private

  def sync
  end
end
