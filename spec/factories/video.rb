FactoryGirl.define do
  factory :video do
    association :uploader, factory: :user
    state 'uploaded'
    anime_id 1
    url 'http://youtube.com/watch?v=VdwKZ6JDENc'
    kind Video::OP

    after :build do |v|
      #v.stub :check_youtube_existence
      #v.stub :fetch_vk_details
      v.stub :suggest_acception
    end

    trait :confirmed do
      state 'confirmed'
    end

    trait :deleted do
      state 'deleted'
    end

    #trait :with_http_request do
      #after(:build) do |v|
        #v.unstub :check_youtube_existence
        #v.unstub :fetch_vk_details
      #end
    #end
  end
end
