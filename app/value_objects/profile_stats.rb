class ProfileStats < Dry::Struct
  attribute :activity, Types::Strict::Hash
  attribute :anime_ratings, Types::Strict::Array
  attribute :anime_spent_time, Types::ShikiSpentTime.optional
  attribute :full_statuses, Types::Strict::Hash
  attribute :is_anime, Types::Strict::Bool
  attribute :is_manga, Types::Strict::Bool
  attribute :kinds, Types::Strict::Hash
  attribute :list_counts, Types::Strict::Hash
  attribute :manga_spent_time, Types::ShikiSpentTime.optional
  attribute :scores, Types::Strict::Hash
  attribute :spent_time, Types::ShikiSpentTime
  attribute :stats_bars, Types::Strict::Array
  attribute :statuses, Types::Strict::Hash
  attribute :user, Types::ShikiUser
  attribute :genres, Types::Strict::Hash
  attribute :studios, Types::Strict::Hash
  attribute :publishers, Types::Strict::Hash
end
