FactoryGirl.define do
  factory :version do
    item { build_stubbed :anime }
    user nil
    state :pending
    item_diff name: ['a', 'b']
  end

  factory :description_version, parent: :version, class: 'Versions::DescriptionVersion' do
  end

  factory :screenshots_version, parent: :version, class: 'Versions::ScreenshotsVersion' do
  end

  factory :video_version, parent: :version, class: 'Versions::VideoVersion' do
  end

  factory :version_anime_video, parent: :version do
    item_type AnimeVideo.name
    state :auto_accepted
  end
end
