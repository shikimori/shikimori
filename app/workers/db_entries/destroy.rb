class DbEntries::Destroy
  include Sidekiq::Worker

  Type = Types::Coercible::String
    .enum(Anime.name, Manga.name, Character.name, Person.name)

  sidekiq_options queue: :dangerous_actions

  def perform type, id, user_id
    NamedLogger.destroy.info "#{type}##{id} User##{user_id}"

    klass = Type[type].constantize

    DbEntry::Destroy.call klass.find(id)
  rescue ActiveRecord::RecordNotFound
  end
end
