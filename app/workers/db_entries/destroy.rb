class DbEntries::Destroy
  include Sidekiq::Worker
  sidekiq_options queue: :dangerous_actions

  Type = Types::Coercible::String
    .enum(Anime.name, Manga.name, Character.name, Person.name)

  def perform type, id, user_id
    NamedLogger.destroy.info "#{type}##{id} User##{user_id}"

    klass = Type[type].constantize

    DbEntry::Destroy.call klass.find(id)
  rescue ActiveRecord::RecordNotFound
  end
end
