class Animes::LinkSmotretAnime
  include Sidekiq::Worker
  sidekiq_options queue: :slow_parsers

  API_URL = 'https://smotretanime.ru/api/series/?myAnimeListId=%<mal_id>i&fields=id,title,links'
  SMOTRET_ANIME_URL = 'https://smotretanime.ru/catalog/%<smotret_anime_id>i'

  GIVE_UP_INTERVAL = 1.month

  def perform anime_id
    anime = Anime.find_by id: anime_id
    return unless anime&.mal_id
    return if disabled? anime

    data = parse fetch anime.mal_id

    if data
      cleanup anime
      process anime, data

    elsif give_up? anime
      give_up anime
    end
  end

private

  def process anime, data
    anime.all_external_links.create!(
      kind: Types::ExternalLink::Kind[:smotret_anime],
      source: Types::ExternalLink::Kind[:smotret_anime],
      url: format(SMOTRET_ANIME_URL, smotret_anime_id: data[:id])
    )

    valuable_links(data[:links]).each do |link|
      next if present_link? anime, link[:kind]

      anime.all_external_links.create!(
        kind: link[:kind],
        url: link[:url],
        source: Types::ExternalLink::Source[:smotret_anime]
      )
    end
  end

  def cleanup anime
    anime
      .all_external_links
      .where(source: Types::ExternalLink::Source[:smotret_anime])
      .delete_all
  end

  def valuable_links links
    links.map do |link|
      {
        kind: Types::ExternalLink::Kind[
          link[:title].strip.downcase.underscore.tr(' ', '_').to_sym
        ],
        url: link[:url]
      }
    rescue Dry::Types::ConstraintError
    end
    .compact
    .reject { |link| link[:kind] == Types::ExternalLink::Kind[:myanimelist] }
  end

  def disabled? anime
    anime.all_external_links.any?(&:kind_smotret_anime?) &&
      !Animes::SmotretAnimeId.call(anime)
  end

  def give_up? anime
    (anime.ongoing? || anime.released?) &&
      anime.aired_on && anime.aired_on < GIVE_UP_INTERVAL.ago
  end

  def give_up anime
    anime.all_external_links.create!(
      kind: Types::ExternalLink::Kind[:smotret_anime],
      source: Types::ExternalLink::Kind[:smotret_anime],
      url: format(SMOTRET_ANIME_URL, smotret_anime_id: Animes::SmotretAnimeId::NO_ID)
    )
  end

  def present_link? anime, kind
    anime.all_external_links.any? do |external_link|
      external_link.source_shikimori? && external_link.kind == kind
    end
  end

  def fetch mal_id
    OpenURI.open_uri(
      format(API_URL, mal_id: mal_id), 'User-Agent' => 'shikimori'
    ).read
  end

  def parse data
    JSON.parse(data, symbolize_names: true).dig(:data, 0)
  end
end
