FactoryGirl.define do
  factory :anime_video do
    sequence(:url) { |n| "http://vk.com/video/#{n}" }
    source 'http://source.com'
    kind AnimeVideo.kind.values.first
    anime { seed :anime }
    episode 1
    author nil
    state 'working'

    after :build do |video|
      #video.class.skip_callback(:create, :after, :create_episode_notificaiton)
      video.stub :create_episode_notificaiton
    end

    AnimeVideo.kind.values.each do |video_kind|
      trait(video_kind.to_sym) { kind video_kind }
    end

    AnimeVideo.state_machine.states.map(&:value).each do |video_state|
      trait(video_state.to_sym) { state video_state }
    end

    trait :with_notification do
      #after(:create) { |video| video.send(:create_episode_notificaiton) }
      after(:build) { |video| video.unstub :create_episode_notificaiton }
    end
  end
end
