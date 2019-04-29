FactoryBot.define do
  factory :video do
    state { 'uploaded' }
    anime { create :anime }
    url { 'http://youtube.com/watch?v=VdwKZ6JDENc' }
    kind { :op }
    uploader { seed :user }

    trait :uploaded do
      state { 'uploaded' }
    end

    trait :confirmed do
      state { 'confirmed' }
    end

    trait :deleted do
      state { 'deleted' }
    end

    # trait :with_http_request do
      # after(:build) do |v|
        # v.unstub :check_youtube_existence
        # v.unstub :fetch_vk_details
      # end
    # end
  end
end
