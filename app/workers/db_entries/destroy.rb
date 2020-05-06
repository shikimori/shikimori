class DbEntries::Destroy
  include Sidekiq::Worker

  Type = Types::Coercible::String
    .enum(Anime.name, Manga.name, Character.name, Person.name)

  sidekiq_options(
    unique: :until_executed,
    unique_args: ->(args) { args[0..2].join('-') },
    queue: :high_priority,
    retry: false
  )

  def perform type, id, user_id
    RedisMutex.with_lock("DbEntries::Destroy-#{type}-#{id}", block: 0) do
      NamedLogger.destroy.info "#{type}##{id} User##{user_id}"

      klass = Type[type].constantize

      klass.find(id).destroy!
    end
  rescue ActiveRecord::RecordNotFound
  end
end
