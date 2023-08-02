class Types::CharacterType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::DescriptionFields

  def synonyms
    [object.altname]
  end

  field :is_anime, Boolean
  field :is_manga, Boolean
  field :is_ranobe, Boolean
end
