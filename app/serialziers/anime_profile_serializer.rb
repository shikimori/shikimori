class AnimeProfileSerializer < AnimeSerializer
  attributes :rating, :english, :japanese, :synonyms, :kind, :aired_at, :released_at
  attributes :episodes, :episodes_aired, :duration, :score, :description, :description_html
  attributes :favoured?, :anons?, :ongoing?, :thread_id

  has_many :genres
  has_many :studios

  has_one :user_rate

  def user_rate
    AnimeRateSerializer.new object.rate
  end

  def thread_id
    object.thread.id
  end
end
