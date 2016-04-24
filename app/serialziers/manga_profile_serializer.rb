class MangaProfileSerializer < MangaSerializer
  attributes :english, :japanese, :synonyms, :kind, :aired_on, :released_on,
    :volumes, :chapters, :score, :description, :description_html,
    :favoured?, :anons?, :ongoing?, :thread_id, :topic_id,
    :read_manga_id, :myanimelist_id,
    :rates_scores_stats, :rates_statuses_stats

  has_many :genres
  has_many :publishers

  has_one :user_rate

  def user_rate
    object.current_rate
  end

  # TODO: deprecated
  def thread_id
    object.topic.try :id
  end

  def topic_id
    object.topic.try :id
  end

  def myanimelist_id
    object.id
  end

  def description
    if scope.ru_domain?
      object[:description_ru] || object[:description_en]
    else
      object[:description_en]
    end
  end

  def description_html
    object.description_html.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end
end
