FactoryGirl.define do
  factory :user_preferences do
    user { seed :user }
    list_privacy :public
    forums [
      Topic::FORUM_IDS['Review'],
      Topic::FORUM_IDS['Anime'],
      Topic::FORUM_IDS['Contest'],
      Topic::FORUM_IDS['Group'],
      Topic::FORUM_IDS['CosplayGallery'],
    ]
  end
end
