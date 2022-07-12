# touches all related db_entries in order to invalidate their cach
class Animes::TouchRelated
  include Sidekiq::Worker
  sidekiq_options queue: :low_priority

  def perform id, type # rubocop:disable all
    db_entry = type.constantize.find id

    touch db_entry.animes if db_entry.respond_to? :animes
    touch db_entry.mangas if db_entry.respond_to? :mangas
    touch db_entry.people if db_entry.respond_to? :people
    touch db_entry.characters if db_entry.respond_to? :characters

    touch db_entry.related_animes if db_entry.respond_to? :related_animes
    touch db_entry.related_mangas if db_entry.respond_to? :related_mangas

    touch db_entry.similar_animes if db_entry.respond_to? :similar_animes
    touch db_entry.similar_mangas if db_entry.respond_to? :similar_mangas
  end

private

  def touch scope
    scope.update_all updated_at: Time.zone.now
  end
end
