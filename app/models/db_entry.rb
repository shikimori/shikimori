class DbEntry < ApplicationRecord
  self.abstract_class = true

  RESTRICTED_FIELDS = %w[
    name
    image
    poster
    genres
    censored
    desynced
    options
  ]

  def cache_key
    super + '/' + to_param
  end

  def self.inherited klass
    super
    klass.before_save :touch_related
  end

  def to_param
    @to_param ||= begin
      # change ids to new ones because of google DMCA bans
      changed_id = CopyrightedIds.instance.change id, self.class.base_class.name.downcase
      "#{changed_id}-#{name.permalinked}"
    end
  end

  def anime?
    instance_of? Anime
  end

  def kinda_manga?
    !!(self.class <= Manga)
  end

  def manga?
    instance_of? Manga
  end

  def ranobe?
    instance_of? Ranobe
  end

  def topic_user
    BotsService.get_poster
  end

  def touch_related
    return unless changes[:name] || changes[:russian]

    Animes::TouchRelated.perform_in 3.seconds, id, self.class.base_class.name
  end

  def mal_url
    return unless mal_id

    "http://myanimelist.net/#{self.class.base_class.name.downcase}/#{mal_id}"
  end
end
