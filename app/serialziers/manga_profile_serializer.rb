class MangaProfileSerializer < MangaSerializer
  attributes :english, :japanese, :synonyms, :kind, :aired_on, :released_on
  attributes :volumes, :chapters, :score, :description, :description_html
  attributes :favoured?, :anons?, :ongoing?, :thread_id
  attributes :read_manga_id, :myanimelist_id
  attributes :rates_scores_stats, :rates_statuses_stats

  has_many :genres
  has_many :publishers

  has_one :user_rate

  def user_rate
    object.rate
  end

  def thread_id
    object.thread.id
  end

  def myanimelist_id
    object.id
  end
end
