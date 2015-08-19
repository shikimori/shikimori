class ImportListWorker
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  unique_args: -> (args) { args }

  def perform options
    options = HashWithIndifferentAccess.new options

    klass = (options[:type] || 'Anime').constantize
    pages_limit = options[:pages_limit] || 10
    hours_limit = options[:hours_limit] || 8
    source = options[:source] || :updated

    entry_ids = case source.to_sym
      when :updated
        Object.const_get("#{klass.name}MalParser").new.fetch_list_pages(limit: pages_limit, url_getter: :updated_catalog_url)

      when :all # 36750 (735 pages) mangas, 10900 (218 pages) animes
        Object.const_get("#{klass.name}MalParser").new.fetch_list_pages(limit: pages_limit, url_getter: :all_catalog_url)

      when :anons, :ongoing, :latest
        AnimeStatusQuery.new(Anime.all).by_status(source).pluck(:id)

      else
        raise "unknown source: #{source}"
    end

    entries = klass
      .where('imported_at < ?', hours_limit.hours.ago)
      .where(id: entry_ids)
      .pluck(:id)

    roles = PersonRole.where("#{klass.name.downcase}_id".to_sym => entries)
    characters = Character
      .where('imported_at < ?', (hours_limit*10).hours.ago)
      .where(id: roles.map(&:character_id).compact.uniq)
      .pluck(:id)

    people = Person
      .where('imported_at < ?', (hours_limit*10).hours.ago)
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
