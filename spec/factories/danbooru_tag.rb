FactoryBot.define do
  factory :danbooru_tag do
    sequence(:name) { |n| "danbooru_tag_#{n}" }

    trait :copyright do
      kind { DanbooruTag::COPYRIGHT }
    end

    trait :character do
      kind { DanbooruTag::CHARACTER }
    end
  end
end
