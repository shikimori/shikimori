FactoryGirl.define do
  factory :anime_video_author do
    sequence(:name) { |n| "author_#{n}" }
  end
end
