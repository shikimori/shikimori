class DbEntries::Destroy
  include Sidekiq::Worker

  Type = Types::Coercible::String
    .enum(Anime.name, Manga.name, Character.name, Person.name)

  sidekiq_options(
    queue: :high_priority,
    retry: false
  )

  def perform type, id, user_id
    NamedLogger.destroy.info "#{type}##{id} User##{user_id}"

    klass = Type[type].constantize

    klass.find(id).destroy!
  end
end
