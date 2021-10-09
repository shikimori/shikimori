class DbImport::Character < DbImport::ImportBase
  SPECIAL_FIELDS = %i[synopsis image seyu]
  ALLOW_BLANK_FIELDS = %i[image seyu]

private

  def assign_seyu seyu
    cleanup_people_roles
    DbImport::PersonRoles.call entry, [], seyu
  end

  def cleanup_people_roles
    PersonRole
      .where(character_id: entry.id)
      .where.not(person_id: nil)
      .delete_all
  end
end
