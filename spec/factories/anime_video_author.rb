FactoryBot.define do
  factory :anime_video_author do
    sequence(:name) { |n| "author_#{n}" }
    is_verified { false }
  end
end
