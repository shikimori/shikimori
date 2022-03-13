class Animes::RefreshScoresWorker
  include Sidekiq::Worker

  Type = Types::Coercible::String.enum(Anime.name, Manga.name)

  def perform type, entry_id, global_average
    klass = Type[type].constantize
    entry = klass.find_by id: entry_id
    return unless entry

    Anime::RefreshScore.call entry, global_average
  end
end
