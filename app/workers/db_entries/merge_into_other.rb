class DbEntries::MergeIntoOther
  include Sidekiq::Worker

  Type = Types::Coercible::String
    .enum(Anime.name, Manga.name, Character.name, Person.name)

  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(args) { args[0..2].join('-') },
    queue: :dangerous_actions,
    retry: false
  )

  def perform type, from_id, to_id, user_id
    RedisMutex.with_lock("DbEntries::MergeIntoOther-#{type}-#{from_id}-#{to_id}", block: 0) do
      NamedLogger.merge_into_other.info "#{type}##{from_id} -> #{type}#{to_id} User##{user_id}"

      klass = Type[type].constantize

      DbEntry::MergeIntoOther.call(entry: klass.find(from_id), other: klass.find(to_id))
    end
  rescue ActiveRecord::RecordNotFound
  end
end
