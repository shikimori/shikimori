FactoryGirl.define do
  factory :cosplay_gallery do
    confirmed true
    deleted false
    sequence(:target) { |n| "character_#{n}" }

    trait :anime do
      after :build do |cosplay_gallery|
        anime = FactoryGirl.create :anime
        FactoryGirl.create :cosplay_gallery_link, cosplay_gallery: cosplay_gallery, linked: anime
      end
    end
  end
end
