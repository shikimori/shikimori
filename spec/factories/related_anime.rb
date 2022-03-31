FactoryBot.define do
  factory :related_anime do
    source { nil }
    anime { nil }
    manga { nil }
    relation { 'Other' }
  end
end
