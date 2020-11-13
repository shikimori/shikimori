class MangaProfileSerializer < MangaSerializer
  attributes :english, :japanese, :synonyms, :kind, :license_name_ru, :aired_on, :released_on,
    :volumes, :chapters, :score,
    :description, :description_html, :description_source, :franchise,
    :favoured, :anons, :ongoing, :thread_id, :topic_id,
    :myanimelist_id,
    :rates_scores_stats, :rates_statuses_stats,
    :licensors

  has_many :genres
  has_many :publishers

  has_one :user_rate

  def description
    object.description.text
  end

  def user_rate
    UserRateFullSerializer.new(object.current_rate) if object.current_rate
  end

  def english
    [object.english]
  end

  def japanese
    [object.japanese]
  end

  # TODO: deprecated
  def thread_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def topic_id
    object.maybe_topic(scope.locale_from_host).id
  end

  def myanimelist_id
    object.id
  end

  def description
    object.description.text
  end

  def description_html
    object.description_html.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end

  def description_source
    object.description.source
  end

  def favoured
    object.favoured?
  end

  def ongoing
    object.ongoing?
  end

  def anons
    object.anons?
  end
end
