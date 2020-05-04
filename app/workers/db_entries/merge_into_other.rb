class DbEntries::MergeIntoOther
  include Sidekiq::Worker

  Type = Types::Coercible::String.enum(Anime.name, Manga.name, Character.name, Person.name)

  sidekiq_options(
    queue: :high_priority,
    retry: false
  )

  def perform type, from_id, to_id, user_id
    NamedLogger.merge_into_other.info "#{from_id} #{to_id} #{type} #{user_id}"
    klass = Type[type].constantize

    DbEntry::MergeIntoOther.call(entry: klass.find(from_id), other: klass.find(to_id))
  end
end
