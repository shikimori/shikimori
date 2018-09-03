FactoryBot.define do
  factory :club_image do
    club { nil }
    user { seed :user }
    image { open "#{Rails.root}/spec/files/anime.jpg" }
  end
end
