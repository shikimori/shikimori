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
  end

  def build person_roles, target_id_key
    person_roles.map do |person_role|
      PersonRole.new(
        entry_id_key => @target.id,
        target_id_key => person_role[:id],
        role: person_role[:role]
      )
    end
  end

  def entry_id_key
    "#{@target.class.base_class.name.downcase}_id".to_sym
  end
end
