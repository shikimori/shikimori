FactoryGirl.define do
  factory :anime_video_report do
    kind AnimeVideoReport.kind.values.first
    state 'pending'
    user_agent 'ipad'

    trait :uploaded do
      kind 'uploaded'
    end

    trait :accepted do
      state 'accepted'
    end

    trait :rejected do
      state 'rejected'
    end

    after :build do |v|
      v.anime_video = FactoryGirl.build_stubbed(:anime_video) unless v.anime_video_id
      v.user = FactoryGirl.build_stubbed(:user) unless v.user_id
      v.approver = FactoryGirl.build_stubbed(:user) unless v.user_id && v.pending?
    end

    trait :with_video do
      anime_video { FactoryGirl.create :anime_video, :uploaded }
    end

    trait :with_user do
      user { FactoryGirl.create :user, :user }
    end
  end
end
