class Types::CharacterType < Types::BaseObject
  include Types::Concerns::DbEntryFields
  include Types::Concerns::DescriptionFields

  def synonyms
    [object.altname].compact
  end

  field :is_anime, Boolean, null: false
  field :is_manga, Boolean, null: false
  field :is_ranobe, Boolean, null: false
end
