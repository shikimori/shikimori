class Import::Refresh
  method_object :klass, :ids, :refresh_interval

  def call
    # refresh @klass, expired_entries
    # roles = PersonRole.where("#{klass.name.downcase}_id".to_sym => entries)
    # characters = Character
      # .where('imported_at < ?', (hours_limit*10).hours.ago)
      # .where(id: roles.map(&:character_id).compact.uniq)
      # .pluck(:id)

    # people = Person
      # .where('imported_at < ?', (hours_limit*10).hours.ago)
      # .where(id: roles.map(&:person_id).compact.uniq)
      # .pluck(:id)

    # unless entries.empty?
      # klass.connection.
        # execute("update #{klass.name.tableize} set imported_at=null where id in (#{entries.join(', ')})")
      # print "#{klass.name.tableize}: %d\n" % entries.size
    # end

    # unless characters.empty?
      # Character.connection.
        # execute("update characters set imported_at=null where id in (#{characters.join(', ')})")
      # print "characters: %d\n" % characters.size
    # end

    # unless people.empty?
      # Person.connection.
        # execute("update people set imported_at=null where id in (#{people.join(', ')})")
      # print "people: %d\n" % people.size
    # end
  end

private

  def refresh klass, scope
    klass.where(id: scope).update_all imported_at: nil
  end

  def expired_entries
    @klass
      .where('imported_at < ?', @refresh_interval.ago)
      .where(id: @ids)
  end
end
