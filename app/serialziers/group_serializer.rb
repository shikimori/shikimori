class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :logo

  def logo
    object.logo.url :x48
  end
end
