FactoryBot.define do
  factory :anime_stat_history do
    scores_stats { [] }
    list_stats { [] }
    score_2 { 0 }
    anime_id { nil }
    manga_id { nil }
    created_on { Time.zone.today }
  end
end
