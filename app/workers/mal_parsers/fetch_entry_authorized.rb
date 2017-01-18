class MalParsers::FetchEntryAuthorized
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executed,
    unique_args: -> (args) { 'only_one_task' },
    queue: :mal_parsers
  )

  def perform anime_id
    Import::Anime.call MalParsers::AnimeAuthorized.call(anime_id)
  end
end
