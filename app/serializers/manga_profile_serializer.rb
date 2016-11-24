class MangaProfileSerializer < MangaSerializer
  attributes :english, :japanese, :synonyms, :kind, :aired_on, :released_on,
    :volumes, :chapters, :score,
    :description, :description_html, :description_source,
    :favoured?, :anons?, :ongoing?, :thread_id, :topic_id,
    :read_manga_id, :myanimelist_id,
    :rates_scores_stats, :rates_statuses_stats

  has_many :genres
  has_many :publishers

  has_one :user_rate

  def user_rate
    UserRateFullSerializer.new(object.current_rate)
  end

  def english
    [object.english]
  end

  def japanese
    [object.japanese]
  end

  # TODO: deprecated
  def thread_id
    object.maybe_topic(scope.locale_from_domain).id
  end

  def topic_id
    object.maybe_topic(scope.locale_from_domain).id
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
end
