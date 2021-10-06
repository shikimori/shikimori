class DbImport::Character < DbImport::ImportBase
  SPECIAL_FIELDS = %i[synopsis image seyu]
  ALLOW_BLANK_FIELDS = %i[image seyu]

private

  def assign_seyu seyu
    DbImport::PersonRoles.call entry, [], seyu, is_clenanup_empty: true
  end
end
