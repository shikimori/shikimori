FactoryBot.define do
  factory :screenshot do
    image { File.new "#{Rails.root}/spec/files/anime.jpg" }
    anime { create :anime }
    url { rand }
    position { rand * 1_000_000 }

    trait :uploaded do
      status { Screenshot::UPLOADED }
    end

    after :build do |user_image|
      user_image.stub :set_dimentions
    end
  end
end
