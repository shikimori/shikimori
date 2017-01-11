class Import::Character < Import::ImportBase
  SPECIAL_FIELDS = %i(synopsis image seyu)

private

  def assign_seyu seyu
    Import::PersonRoles.call entry, [], seyu
  end
end
