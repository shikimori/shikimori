class Types::GenreType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :russian, String, null: false
  field :kind, Types::Enums::Genre::KindEnum, null: false
  field :entry_type, Types::Enums::Genre::EntryTypeEnum, null: false
end
