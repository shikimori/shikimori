class MangaWithRoleSerializer < MangaSerializer
  attribute :role do
    object.role
  end
end
