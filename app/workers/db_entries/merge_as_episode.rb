class DbEntries::MergeAsEpisode
  include Sidekiq::Worker
  sidekiq_options queue: :dangerous_actions

  Type = Types::Coercible::String.enum(Anime.name, Manga.name)
  AnimeEpisodeField = Types::Coercible::Symbol.enum(:episodes)
  MangaEpisodeField = Types::Coercible::Symbol.enum(:volumes, :chapeters)

  def perform type, from_id, to_id, episode, episode_field, user_id # rubocop:disable ParameterLists
    NamedLogger.merge_as_episode.info(
      "#{type}##{from_id} -> #{type}#{to_id} Episode##{episode} " \
        "EpisodeField##{episode_field} User##{user_id}"
    )

    klass = Type[type].constantize

    DbEntry::MergeAsEpisode.call(
      entry: klass.find(from_id),
      other: klass.find(to_id),
      episode: episode,
      episode_field: self.class.const_get("#{klass.name}EpisodeField")[episode_field]
    )
  rescue ActiveRecord::RecordNotFound
  end
end
