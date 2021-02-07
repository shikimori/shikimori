FactoryBot.define do
  factory :anime_stat_history do
    scores_stats { [] }
    list_stats { [] }
    entry { nil }
    created_on { Time.zone.today }
  end
end
