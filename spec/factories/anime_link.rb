FactoryBot.define do
  factory :anime_link do
    service { AnimeLink.service.values.first }
  end
end
