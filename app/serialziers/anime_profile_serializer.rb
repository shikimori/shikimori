class AnimeProfileSerializer < AnimeSerializer
  attributes :rating, :english, :japanese, :synonyms, :kind, :aired_on,
    :released_on, :episodes, :episodes_aired, :duration, :score, :description,
    :description_html, :favoured?, :anons?, :ongoing?, :thread_id,
    :world_art_id, :myanimelist_id, :ani_db_id,
    :rates_scores_stats, :rates_statuses_stats

  has_many :genres
  has_many :studios
  has_many :videos
  has_many :screenshots

  has_one :user_rate

  def user_rate
    object.current_rate
  end

  def thread_id
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

  def videos
    object.videos 2
  end

  def screenshots
    object.screenshots 2
  end
end
