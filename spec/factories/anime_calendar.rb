FactoryGirl.define do
  factory :anime_calendar do
    episode 1
    start_at DateTime.now+1.week
  end
end
