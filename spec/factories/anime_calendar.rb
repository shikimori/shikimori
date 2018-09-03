FactoryBot.define do
  factory :anime_calendar do
    episode { 1 }
    start_at { 1.week.from_now }
  end
end
