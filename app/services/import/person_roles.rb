class Import::PersonRoles
  method_object :target, :person_roles, :target_id_key

  def call
    PersonRole.transaction do
      cleanup
      import
    end
  end

private

  def cleanup
    PersonRole.where(entry_id_key => @target.id).delete_all
  end

  def import
    PersonRole.import person_roles
  end

  def person_roles
    @person_roles.map do |person_role|
      PersonRole.new(
        entry_id_key => @target.id,
        @target_id_key => person_role[:id],
        role: person_role[:role]
      )
    end
  end

  def entry_id_key
    "#{@target.class.name.downcase}_id".to_sym
  end
end
