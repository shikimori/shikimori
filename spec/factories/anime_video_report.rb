FactoryBot.define do
  factory :anime_video_report do
    kind { AnimeVideoReport.kind.values.first }
    state { 'pending' }
    user_agent { 'ipad' }
    user { seed :user }

    AnimeVideoReport.kind.values.each do |report_kind|
      trait(report_kind.to_sym) { kind { report_kind } }
    end

    after :build do |v|
      v.anime_video = FactoryBot.build_stubbed(:anime_video) unless v.anime_video_id
      v.approver = FactoryBot.build_stubbed(:user, :user) unless v.user_id && v.pending?
    end

    trait :with_video do
      anime_video { FactoryBot.create :anime_video, :uploaded }
    end

    trait :with_user do
      user { FactoryBot.create :user, :user }
    end
  end
end
