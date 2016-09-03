class GenreSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :kind
end
