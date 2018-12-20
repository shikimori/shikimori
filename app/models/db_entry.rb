class DbEntry < ApplicationRecord
  self.abstract_class = true

  SIGNIFICANT_MAJOR_FIELDS = %w[name license_name_ru genres image]
  SIGNIFICANT_MINOR_FIELDS = %w[duration]

  def cache_key
    super + '/' + to_param
  end

  def self.inherited klass
    super
    klass.before_update :touch_related
  end

  def to_param
    @to_param ||= begin
      # change ids to new ones because of google DMCA bans
      changed_id = CopyrightedIds.instance.change id, self.class.name.downcase
      "#{changed_id}-#{name.permalinked}"
    end
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
    Animes::TouchRelated.perform_async id
  end

  def mal_url
    return unless mal_id
    "http://myanimelist.net/#{self.class.base_class.name.downcase}/#{mal_id}"
  end

  # TODO: uncomment when source field is removed from Anime and Manga
  # def source
  #  raise 'use DbEntryDecorator#description.source instead!'
  # end
end
