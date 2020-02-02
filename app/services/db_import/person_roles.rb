class DbImport::PersonRoles
  method_object :target, :characters, :staff

  def call
    PersonRole.transaction do
      cleanup :character_id if @characters.any?
      cleanup :person_id if @staff.any?

      import(build(@characters, :character_id) + build(@staff, :person_id))
    end
  end

private

  def cleanup target_id_key
    PersonRole
      .where(entry_id_key => @target.id)
      .where.not(target_id_key => nil)
      .delete_all
  end

  def import person_roles
    PersonRole.import person_roles

    now = Time.zone.now
    Character.where(id: person_roles.map(&:character_id).compact).update_all(updated_at: now)
    Person.where(id: person_roles.map(&:person_id).compact).update_all(updated_at: now)
  end

  def build person_roles, target_id_key
    cleaned_roles = cleanup_banned person_roles, target_id_key

    cleaned_roles.map do |person_role|
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
