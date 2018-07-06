class DbImport::Character < DbImport::ImportBase
  SPECIAL_FIELDS = %i[synopsis image seyu]

private

  def assign_seyu seyu
    DbImport::PersonRoles.call entry, [], seyu
  end
end
