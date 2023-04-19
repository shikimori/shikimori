class GenreSerializer < ActiveModel::Serializer
  attributes :id, :name, :russian, :kind

  def kind
    nil
  end
end
