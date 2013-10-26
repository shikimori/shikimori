FactoryGirl.define do
  factory :image do
    sequence(:image_file_name) { |n| "image_#{n}" }
  end
end
