class Types::ContestType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :name, String, null: false
  def name
    object.title_ru
  end
end
