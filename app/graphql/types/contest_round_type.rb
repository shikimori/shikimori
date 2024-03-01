class Types::ContestRoundType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false

  field :matches, [Types::ContestMatchType], null: false, complexity: 50

  field :name, String, null: false
  def name
    object.title
  end

  field :number, Integer, null: false
  field :is_additional, Boolean, null: false
  def is_additional # rubocop:disable Nameing/PredicateName
    object.additional
  end
  field :state, Types::Enums::ContestRound::StateEnum, null: false
end
