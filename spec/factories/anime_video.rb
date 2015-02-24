FactoryGirl.define do
  factory :anime_video do
    sequence(:url) { |n| "http://vk.com/video/#{n}" }
    source 'http://source.com'
    kind AnimeVideo.kind.values.first
    anime { FactoryGirl.build_stubbed(:anime) }
    episode 1
    author nil
    state 'working'

    after :build do |video|
      #video.class.skip_callback(:create, :after, :create_episode_notificaiton)
      video.stub :create_episode_notificaiton
    end

    trait :uploaded do
      state 'uploaded'
    end

    trait :with_notification do
      #after(:create) { |video| video.send(:create_episode_notificaiton) }
      after(:build) { |video| video.unstub :create_episode_notificaiton }
    end
  end
end
