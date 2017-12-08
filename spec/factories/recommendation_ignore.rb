FactoryBot.define do
  factory :recommendation_ignore do
    user { seed :user }
    target { create :anime }
  end
end
