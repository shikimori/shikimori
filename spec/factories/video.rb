FactoryGirl.define do
  factory :video do
    uploader_id 1
    state 'uploaded'
    anime_id 1
    url 'http://youtube.com/watch?v=VdwKZ6JDENc'
    kind Video::OP
    after(:build) {|v| v.stub :existence }

    trait :with_existence do
      after(:build) {|v| v.unstub :existence }
    end
  end
end
