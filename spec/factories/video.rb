FactoryBot.define do
  factory :video do
    state { 'uploaded' }
    anime { create :anime }
    url { 'http://youtube.com/watch?v=VdwKZ6JDENc' }
    kind { :op }
    uploader { seed :user }

    Video.aasm.states.map(&:name).each do |value|
      trait(value.to_sym) { state { value } }
    end

    # trait :with_http_request do
      # after(:build) do |v|
        # v.unstub :check_youtube_existence
        # v.unstub :fetch_vk_details
      # end
    # end
  end
end
