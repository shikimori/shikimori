class CollectionSerializer < ActiveModel::Serializer
  attributes :id, :kind, :name, :text, :state, :autocomplete_url
  has_one :user
  has_many :links

  def autocomplete_url
    scope.send :"autocomplete_#{object.kind.pluralize}_url"
  end
end
