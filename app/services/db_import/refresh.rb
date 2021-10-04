class DbImport::Refresh
  method_object :klass, :ids, :refresh_interval

  def call
    if klass < AniManga
      refresh Character, expired_characters
      refresh Person, expired_people
    end

    refresh @klass, expired_entries
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

  def expired_characters
    ids = expired_roles.where.not(character_id: nil).select(:character_id)

    Character
      .where('imported_at < ?', @refresh_interval.ago)
      .where(id: ids)
  end

  def expired_people
    ids = expired_roles.where.not(person_id: nil).select(:person_id)

    Person
      .where('imported_at < ?', @refresh_interval.ago)
      .where(id: ids)
  end

  def expired_roles
    PersonRole
      .where("#{klass.name.downcase}_id".to_sym => expired_entries)
  end
end
