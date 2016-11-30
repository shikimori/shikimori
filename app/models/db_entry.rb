class DbEntry < ActiveRecord::Base
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

  # аниме ли это?
  def anime?
    self.class == Anime
  end

  # манга ли это?
  def manga?
    self.class == Manga
  end

  def topic_user
    BotsService.get_poster
  end

  def touch_related
    return unless changes[:name] || changes[:russian]
    DbEntries::TouchRelated.perform_async id
  end

  def mal_url
    "http://myanimelist.net/#{self.class.name.downcase}/#{id}"
  end

  # TODO: remove when source field is removed from anime, manga and character
  def source
    raise 'use DbEntryDecorator#description.source instead!'
  end
end
