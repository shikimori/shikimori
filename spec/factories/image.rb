FactoryGirl.define do
  factory :image do
    image { File.new(Rails.root.join('spec', 'images', 'anime.jpg')) }
  end
end
