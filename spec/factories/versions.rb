FactoryGirl.define do
  factory :version do
    item_id 1
    item_type "MyString"
    item_diff "{}"
    user_id 1
    state "MyString"

  end

  factory :version_anime_video, parent: :version do
    item_type AnimeVideo.name
    state :accepted_pending
  end
end
