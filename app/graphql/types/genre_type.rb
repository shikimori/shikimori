class Types::GenreType < Types::BaseObject
  field :id, ID
  field :name, String
  field :russian, String
  field :kind, Types::Enums::Genre::KindEnum
  field :entry_type, Types::Enums::Genre::EntryTypeEnum

  def kind
    Types::GenreV2::Kind[:genre].to_s
  end

  def entry_type
    object.kind.to_s.capitalize
  end
end
