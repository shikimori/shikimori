class ImportListWorker
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  unique_args: -> (args) { args }

  def perform options
    klass = (options[:type] || 'Anime').constantize
    pages_limit = options[:pages_limit] || 10
    hours_limit = options[:hours_limit] || 8
    source = options[:source] || :updated

    entry_ids = case source
      when :updated
        Object.const_get("#{klass.name}MalParser").new.fetch_list_pages(limit: pages_limit, url_getter: :updated_catalog_url)

      when :all
        Object.const_get("#{klass.name}MalParser").new.fetch_list_pages(limit: pages_limit, url_getter: :all_catalog_url)

      when :anons
        Anime.anons.pluck(:id)

      when :ongoing
        Anime.ongoing.pluck(:id)

      when :latest
        Anime.latest.map(&:id)
    end

    entries = klass
      .where("imported_at < date_add(now(), interval -#{hours_limit} hour)")
      .where(id: entry_ids)
      .pluck(:id)

    roles = PersonRole.where("#{klass.name.downcase}_id".to_sym => entries)
    characters = Character
      .where("imported_at < date_add(now(), interval -#{hours_limit*10} hour)")
      .where(id: roles.map(&:character_id).compact.uniq)
      .pluck(:id)

    people = Person
      .where("imported_at < date_add(now(), interval -#{hours_limit*10} hour)")
      .where(id: roles.map(&:person_id).compact.uniq)
      .pluck(:id)

    unless entries.empty?
      klass.connection.
        execute("update #{klass.name.tableize} set imported_at=null where id in (#{entries.join(', ')})")
      print "#{klass.name.tableize}: %d\n" % entries.size
    end

    unless characters.empty?
      Character.connection.
        execute("update characters set imported_at=null where id in (#{characters.join(', ')})")
      print "characters: %d\n" % characters.size
    end

    unless people.empty?
      Person.connection.
        execute("update people set imported_at=null where id in (#{people.join(', ')})")
      print "people: %d\n" % people.size
    end
  end
end
