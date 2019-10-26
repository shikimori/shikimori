FactoryBot.define do
  factory :user_image do
    image { open "#{Rails.root}/spec/files/anime.jpg" }
    user { seed :user }
    width { 1000 }
    height { 1000 }

    after :build do |user_image|
      user_image.stub :set_dimentions
    end
  end
end
