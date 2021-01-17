class Users::ProfileStats
  include ShallowAttributes

  attribute :activity, Hash
  attribute :anime_ratings, Array, of: Profiles::CriteriaStat
  attribute :anime_spent_time, SpentTime
  attribute :full_statuses, Hash
  attribute :is_anime, Boolean
  attribute :is_manga, Boolean
  attribute :kinds, Hash
  attribute :list_counts, Hash
  attribute :manga_spent_time, SpentTime
  attribute :scores, Hash
  attribute :spent_time, SpentTime
  attribute :stats_bars, Array, of: Profiles::BarStats
  attribute :statuses, Hash
  attribute :genres, Hash
  attribute :studios, Hash
  attribute :publishers, Hash
end
