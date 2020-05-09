class DbEntries::Destroy
  include Sidekiq::Worker

  Type = Types::Coercible::String
    .enum(Anime.name, Manga.name, Character.name, Person.name)

  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(args) { args[0..2].join('-') },
    queue: :dangerous_actions
  )

  def perform type, id, user_id
    RedisMutex.with_lock("DbEntries::Destroy-#{type}-#{id}", block: 0, expire: 2.hours) do
      NamedLogger.destroy.info "#{type}##{id} User##{user_id}"

      klass = Type[type].constantize

      DbEntry::Destroy.call klass.find(id)
    end
  rescue ActiveRecord::RecordNotFound
  end
end
