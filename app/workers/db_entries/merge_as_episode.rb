class DbEntries::MergeAsEpisode
  include Sidekiq::Worker
  sidekiq_options queue: :dangerous_actions

  Type = Types::Coercible::String
    .enum(Anime.name, Manga.name, Character.name, Person.name)

  def perform type, from_id, to_id, episode, user_id
    NamedLogger.merge_as_episode.info(
      "#{type}##{from_id} -> #{type}#{to_id} Episode##{episode} User##{user_id}"
    )

    klass = Type[type].constantize

    DbEntry::MergeIntoAsEpisode.call(
      entry: klass.find(from_id),
      other: klass.find(to_id),
      episode: episode
    )
  rescue ActiveRecord::RecordNotFound
  end
end
