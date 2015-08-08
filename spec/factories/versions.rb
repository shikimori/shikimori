FactoryGirl.define do
  factory :version do
    item nil
    user nil
    state :pending
    item_diff name: ['a', 'b']
  end

  factory :version_anime_video, parent: :version do
    item_type AnimeVideo.name
    state :accepted_pending
  end
end
