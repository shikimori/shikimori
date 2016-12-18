FactoryGirl.define do
  factory :external_link do
    entry nil
    source 'anime_db'
    url 'http://test.com'
    imported_at nil

    Types::ExternalLink::Source.values.each do |v|
      trait v.to_sym do
        source v
      end
    end
  end
end
