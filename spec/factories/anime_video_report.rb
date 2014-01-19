FactoryGirl.define do
  factory :anime_video_report do
    kind AnimeVideoReport.kind.values.first
    state 'pending'
    user_agent 'ipad'

    after :build do |v|
      v.anime_video = FactoryGirl.build_stubbed(:anime_video) unless v.anime_video_id
      v.user = FactoryGirl.build_stubbed(:user) unless v.user_id
    end
  end
end
