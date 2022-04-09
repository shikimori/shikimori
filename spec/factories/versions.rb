FactoryBot.define do
  factory :version do
    item { create :anime }
    associated { nil }
    user { seed :user }
    state { :pending }
    item_diff { { russian: ['a', 'b'] } }

    # Version.state_machine.states.map(&:value).each do |version_state|
    #   trait(version_state.to_sym) { state { version_state } }
    # end

    factory :description_version, class: 'Versions::DescriptionVersion'
    factory :screenshots_version, class: 'Versions::ScreenshotsVersion'
    factory :video_version, class: 'Versions::VideoVersion'
    factory :genres_version, class: 'Versions::GenresVersion'
    factory :poster_version, class: 'Versions::PosterVersion'
    factory :collection_version, class: 'Versions::CollectionVersion'
    factory :version_anime_video do
      item_type { AnimeVideo.name }
      state { :auto_accepted }
    end
    factory :role_version, class: 'Versions::RoleVersion'
  end
end
