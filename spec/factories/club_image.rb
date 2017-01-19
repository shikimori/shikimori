include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :club_image do
    club nil
    user { seed :user }
    image { fixture_file_upload "#{Rails.root}/spec/images/anime.jpg" }
  end
end
