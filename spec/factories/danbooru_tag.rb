FactoryGirl.define do
  factory :danbooru_tag do
    sequence(:name) { |n| "danbooru_tag_#{n}" }
  end
end
