class AnimeWithRoleSerializer < AnimeSerializer
  attribute :role do
    object.role
  end
end
