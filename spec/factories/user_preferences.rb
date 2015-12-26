FactoryGirl.define do
  factory :user_preferences do
    user { seed :user }
    list_privacy :public
    forums [
      DbEntryThread::FORUM_IDS['Review'],
      DbEntryThread::FORUM_IDS['Anime'],
      DbEntryThread::FORUM_IDS['Contest'],
      DbEntryThread::FORUM_IDS['Group'],
      DbEntryThread::FORUM_IDS['CosplayGallery'],
    ]
  end
end
