class Types::GenreType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :russian, String, null: false
  field :kind, Types::Enums::Genre::KindEnum, null: false
  field :entry_type, Types::Enums::Genre::EntryTypeEnum, null: false

  def kind
    Types::GenreV2::Kind[:genre].to_s
  end

  def entry_type
    object.kind.to_s.capitalize
  end
end
