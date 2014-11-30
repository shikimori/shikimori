FactoryGirl.define do
  factory :anime_video_report do
    kind AnimeVideoReport.kind.values.first
    state 'pending'
    user_agent 'ipad'

    factory :uploaded_accepted_report do
      state 'accepted'
      kind 'uploaded'
    end

    factory :uploaded_rejected_report do
      state 'rejected'
      kind 'uploaded'
    end

    after :build do |v|
      v.anime_video = FactoryGirl.build_stubbed(:anime_video) unless v.anime_video_id
      v.user = FactoryGirl.build_stubbed(:user) unless v.user_id
      v.approver = FactoryGirl.build_stubbed(:user) unless v.user_id && v.pending?
    end
  end
end
