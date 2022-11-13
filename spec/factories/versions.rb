FactoryBot.define do
  factory :version do
    item { create :anime }
    associated { nil }
    user { seed :user }
    state { :pending }
    item_diff { { russian: ['a', 'b'] } }

    Version.aasm.states.map(&:name).each do |value|
      trait(value.to_sym) { state { value } }
    end

    factory :description_version, class: 'Versions::DescriptionVersion'
    factory :screenshots_version, class: 'Versions::ScreenshotsVersion'
    factory :video_version, class: 'Versions::VideoVersion'
    factory :genres_version, class: 'Versions::GenresVersion'
    factory :poster_version, class: 'Versions::PosterVersion'
    factory :poster_old_version, class: 'Versions::PosterOldVersion'
    factory :collection_version, class: 'Versions::CollectionVersion'
    factory :version_anime_video do
      item_type { AnimeVideo.name }
      state { :auto_accepted }
    end
    factory :role_version, class: 'Versions::RoleVersion'
  end
end
