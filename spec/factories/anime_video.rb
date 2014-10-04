FactoryGirl.define do
  factory :anime_video do
    url 'http://test.com/video/1'
    source 'http://source.com'
    kind AnimeVideo.kind.values.first
    episode 1
    author nil
    state 'working'

    after :build do |v|
      v.anime = FactoryGirl.build_stubbed(:anime) unless v.anime_id
      v.class.skip_callback(:create, :after, :episode_notification)
    end

    trait :with_notification do
      after(:create) { |video| video.send(:episode_notification) }
    end
  end
end
