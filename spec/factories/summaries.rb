FactoryBot.define do
  factory :summary do
    user { seed :user }
    anime { nil }
    manga { nil }
    body { 'MyText' }
    is_positive { false }
  end
end
