class DbEntry < ApplicationRecord
  self.abstract_class = true
  SIGNIFICANT_FIELDS = %w(name genres image)

  def self.inherited klass
    super

    klass.has_many :club_links, -> { where linked_type: klass.name },
      foreign_key: :linked_id,
      dependent: :destroy

    klass.has_many :clubs, through: :club_links

    klass.before_update :touch_related
  end

  def to_param
    # change ids to new ones because of google bans
    changed_id = CopyrightedIds.instance.change id, self.class.name.downcase
    "#{changed_id}-#{name.permalinked}"
  end

  def anime?
    self.class == Anime
  end

  def kinda_manga?
    self.class <= Manga
  end

  def manga?
    self.class == Manga
  end

  def ranobe?
    self.class == Ranobe
  end

  def topic_user
    BotsService.get_poster
  end

  def touch_related
    return unless changes[:name] || changes[:russian]
    DbEntries::TouchRelated.perform_async id
  end

  def mal_url
    "http://myanimelist.net/#{self.class.base_class.name.downcase}/#{id}"
  end

  # TODO: uncomment when source field is removed from Anime and Manga
  #def source
  #  raise 'use DbEntryDecorator#description.source instead!'
  #end
end
