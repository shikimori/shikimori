class AnimeProfileSerializer < AnimeSerializer
  attributes :rating, :english, :japanese, :synonyms, :kind, :aired_on, :released_on
  attributes :episodes, :episodes_aired, :duration, :score, :description, :description_html
  attributes :favoured?, :anons?, :ongoing?, :thread_id
  attributes :world_art_id, :myanimelist_id, :ani_db_id

  has_many :genres
  has_many :studios

  has_one :user_rate

  def user_rate
    object.rate
  end

  def thread_id
    object.thread.try :id
  end

  def myanimelist_id
    object.id
  end

  def description
    object.description || object[:description_mal]
  end
end
