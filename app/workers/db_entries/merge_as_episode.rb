class DbEntries::MergeAsEpisode
  include Sidekiq::Worker
  sidekiq_options queue: :dangerous_actions

  Type = Types::Coercible::String.enum(Anime.name, Manga.name)
  AnimeEpisodeField = Types::Coercible::Symbol.enum(:episodes)
  MangaEpisodeField = Types::Coercible::Symbol.enum(:volumes, :chapters)

  def perform( # rubocop:disable ParameterLists
    type,
    from_id,
    to_id,
    as_episode,
    episode_label,
    episode_field,
    user_id
  )
    NamedLogger.merge_as_episode.info(
      "#{type}##{from_id} -> #{type}#{to_id} AsEpisode##{as_episode} "\
        "Label##{episode_label} " \
        "EpisodeField##{episode_field} User##{user_id}"
    )

    klass = Type[type].constantize

    DbEntry::MergeAsEpisode.call(
      entry: klass.find(from_id),
      other: klass.find(to_id),
      as_episode: as_episode,
      episode_label: episode_label,
      episode_field: self.class.const_get("#{klass.name}EpisodeField")[episode_field]
    )
  rescue ActiveRecord::RecordNotFound
  end
end
