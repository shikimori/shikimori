class Types::ContestMatchType < Types::BaseObject
  field :id, GraphQL::Types::ID, null: false
  field :state, Types::Enums::ContestMatch::StateEnum, null: false

  field :left_votes, Integer
  def left_votes
    object.cached_votes_up if object.finished?
  end

  field :right_votes, Integer
  def right_votes
    object.cached_votes_down if object.finished?
  end

  field :left_id, Integer
  field :left_anime, Types::AnimeType, complexity: 20
  def left_anime
    object.left if object.left_type == Anime.name
  end
  field :left_character, Types::CharacterType, complexity: 20
  def left_character
    object.left if object.left_type == Character.name
  end

  field :right_id, Integer
  field :right_anime, Types::AnimeType, complexity: 20
  def right_anime
    object.right if object.right_type == Anime.name
  end
  field :right_character, Types::CharacterType, complexity: 20
  def right_character
    object.right if object.right_type == Character.name
  end

  field :winner_id, Integer
end
