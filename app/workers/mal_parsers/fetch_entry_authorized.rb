class MalParsers::FetchEntryAuthorized
  include Sidekiq::Worker

  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(_args) { 'only_one_task' },
    queue: :mal_parsers
  )

  def perform anime_id
    Import::Anime.call parsed_data(anime_id)
    update_authorized_imported_at!(anime_id)
  end

  private

  def parsed_data anime_id
    MalParsers::AnimeAuthorized.(anime_id)
  end

  def update_authorized_imported_at! anime_id
    anime = Anime.find(anime_id)
    anime.update!(authorized_imported_at: Time.zone.now)
  end
end
