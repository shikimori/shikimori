FactoryGirl.define do
  factory :version do
    item { build_stubbed :anime }
    user nil
    state :pending
    item_diff name: ['a', 'b']
  end

  factory :version_anime_video, parent: :version do
    item_type AnimeVideo.name
    state :auto_accepted
  end
end
