FactoryGirl.define do
  factory :screenshot do
    image { File.new "#{Rails.root}/spec/files/anime.jpg" }
    anime { build_stubbed :anime }
    url { rand }
    position { rand * 1_000_000 }

    trait :uploaded do
      status Screenshot::UPLOADED
    end
  end
end
