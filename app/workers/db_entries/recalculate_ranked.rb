class DbEntries::RecalculateRanked
  include Sidekiq::Worker

  Type = Types::Coercible::String.enum(Anime.name, Manga.name)
  Ranked = Types::Coercible::Symbol.enum(:random, :shiki)

  def perform type, ranked
    send(Ranked[ranked], Type[type].constantize)
  end

private

  def random type
    type.select(:id).shuffle.each_with_index do |entry, index|
      entry.update_column(:ranked_random, index + 1)
    end
  end

  def shiki type
    type.order(score_2: :desc).select(:id).each_with_index do |entry, index|
      entry.update_column(:ranked_shiki, index + 1)
    end
  end
end
