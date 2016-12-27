class ProfileStats < Dry::Struct
  constructor_type(:schema)

  attribute :activity, Types::Strict::Hash
  attribute :anime_ratings, Types::Strict::Array
  attribute :anime_spent_time, Types::SpentTime.optional
  attribute :full_statuses, Types::Strict::Hash
  attribute :is_anime, Types::Strict::Bool
  attribute :is_manga, Types::Strict::Bool
  attribute :kinds, Types::Strict::Hash
  attribute :list_counts, Types::Strict::Hash
  attribute :manga_spent_time, Types::SpentTime.optional
  attribute :scores, Types::Strict::Hash
  attribute :spent_time, Types::SpentTime
  attribute :stats_bars, Types::Strict::Array
  attribute :statuses, Types::Strict::Hash
  attribute :user, Types::User
end
