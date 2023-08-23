class GenreSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :kind, :entry_type

  def kind
    Types::GenreV2::Kind[:genre]
  end

  def entry_type
    object.kind.to_s.capitalize
  end
end
