FactoryBot.define do
  factory :version do
    item { create :anime }
    user { seed :user }
    state :pending
    item_diff russian: ['a', 'b']

    Version.state_machine.states.map(&:value).each do |version_state|
      trait(version_state.to_sym) { state version_state }
    end
  end

  factory :description_version, parent: :version, class: 'Versions::DescriptionVersion' do
  end

  factory :screenshots_version, parent: :version, class: 'Versions::ScreenshotsVersion' do
  end

  factory :video_version, parent: :version, class: 'Versions::VideoVersion' do
  end

  factory :genres_version, parent: :version, class: 'Versions::GenresVersion' do
  end

  factory :poster_version, parent: :version, class: 'Versions::PosterVersion' do
  end

  factory :collection_version, parent: :version, class: 'Versions::CollectionVersion' do
  end

  factory :version_anime_video, parent: :version do
    item_type AnimeVideo.name
    state :auto_accepted
  end
end
