FactoryBot.define do
  factory :similar_anime do
    association :src, factory: :anime
    association :dst, factory: :anime
  end
end
