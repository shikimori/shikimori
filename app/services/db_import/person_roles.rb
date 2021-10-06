class DbImport::PersonRoles
  method_object :target, :characters, :staff, %i[is_clenanup_empty]

  def call
    PersonRole.transaction do
      cleanup :character_id if @characters.any? || @is_clenanup_empty
      cleanup :person_id if @staff.any? || @is_clenanup_empty

      character_roles = cleanup_banned @characters, :character_id
      staff_roles = cleanup_banned @staff, :person_id

      results = import(
        build(character_roles, :character_id) + build(staff_roles, :person_id)
      )

      schedule character_roles, Character
      schedule staff_roles, Person

      results
    end
  end

private

  def schedule entries, klass
    ids = entries.pluck(:id)

    (ids - klass.where(id: ids).pluck(:id)).each do |id|
      MalParsers::FetchEntry.perform_in 3.seconds, id, klass.name.downcase
    end
  end

  def cleanup target_id_key
    PersonRole
      .where(entry_id_key => @target.id)
      .where.not(target_id_key => nil)
      .delete_all
  end

  def import person_roles
    PersonRole.import person_roles

    Character
      .where(id: person_roles.map(&:character_id).compact)
      .update_all updated_at: Time.zone.now

    Person
      .where(id: person_roles.map(&:person_id).compact)
      .update_all updated_at: Time.zone.now
  end

  def build person_roles, target_id_key
    person_roles.map do |person_role|
      PersonRole.new(
        entry_id_key => @target.id,
        target_id_key => person_role[:id],
        roles: person_role[:roles]
      )
    end
  end

  def cleanup_banned person_roles, target_id_key
    person_roles.reject do |person_role|
      DbImport::BannedRoles.instance.banned?(
        entry_id_key => @target.id,
        target_id_key => person_role[:id]
      )
    end
  end

  def entry_id_key
    "#{@target.class.base_class.name.downcase}_id".to_sym
  end
end
