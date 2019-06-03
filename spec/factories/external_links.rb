FactoryBot.define do
  factory :external_link do
    entry { nil }
    kind { 'anime_db' }
    source { 'shikimori' }
    url { 'http://test.com' }
    imported_at { nil }

    Types::ExternalLink::Source.values.each do |v|
      trait(v.to_sym) { source { v } }
    end

    Types::ExternalLink::Kind.values.each do |v|
      trait(v.to_sym) { kind { v } }
    end
  end
end
