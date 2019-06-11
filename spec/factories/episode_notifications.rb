FactoryBot.define do
  factory :episode_notification do
    anime { nil }
    episode { 1 }
    is_raw { false }
    is_subtitles { false }
    is_fandub { false }

    after :build do |model|
      stub_method model, :track_episode
    end

    trait :with_track_episode do
      after :build do |model|
        unstub_method model, :track_episode
      end
    end
  end
end
