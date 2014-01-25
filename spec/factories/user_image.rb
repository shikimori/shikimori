FactoryGirl.define do
  factory :user_image do
    image { File.new(Rails.root.join('spec', 'images', 'anime.jpg')) }
    width 1000
    height 1000

    after(:build) do |user_image|
      user_image.stub :set_dimentions
    end
  end
end
