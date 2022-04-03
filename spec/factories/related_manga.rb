FactoryBot.define do
  factory :related_manga do
    source { nil }
    anime { nil }
    manga { nil }
    relation { 'Other' }
  end
end
