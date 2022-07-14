class DbEntries::RecalculateRanked
  include Sidekiq::Worker

  Type = Types::Coercible::String.enum(Anime.name, Manga.name)
  Ranked = Types::Coercible::Symbol.enum(:random, :shiki)

  def perform type, ranked
    klass = Type[type].constantize
    klass.transaction { send Ranked[ranked], klass }
  end

private

  def random klass
    klass.select(:id).shuffle.each_with_index do |entry, index|
      entry.update_column(:ranked_random, index + 1)
    end
  end

  def shiki klass
    klass.order(score_2: :desc).select(:id).each_with_index do |entry, index|
      entry.update_column(:ranked_shiki, index + 1)
    end
  end
end
