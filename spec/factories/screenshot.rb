FactoryGirl.define do
  factory :screenshot do
    image { File.new(Rails.root.join('spec', 'images', 'anime.jpg')) }
    anime_id 1
    url "MyString"
    position 1
  end
end
