describe AnimeOnline::ResponsibleUploaders do
  subject { described_class.call }

  let(:user_enough_accepted) { build_stubbed :user }
  let!(:report_1_1) { create :anime_video_report, :uploaded, :accepted, user: user_enough_accepted }
  let!(:report_1_2) { create :anime_video_report, :uploaded, :accepted, user: user_enough_accepted }

  let(:user_not_enough_accepted) { build_stubbed :user }
  let!(:report_2_1) { create :anime_video_report, :uploaded, :accepted, user: user_not_enough_accepted }

  let(:user_with_enough_rejected) { build_stubbed :user }
  let!(:report_3_1) { create :anime_video_report, :uploaded, :accepted, user: user_with_enough_rejected }
  let!(:report_3_2) { create :anime_video_report, :uploaded, :accepted, user: user_with_enough_rejected }
  let!(:report_3_3) { create :anime_video_report, :uploaded, :rejected, user: user_with_enough_rejected }
  let!(:report_3_4) { create :anime_video_report, :uploaded, :rejected, user: user_with_enough_rejected }

  let(:user_with_not_enough_rejected) { build_stubbed :user }
  let(:video_4) { create :anime_video }
  let!(:report_4_1) do
    create :anime_video_report, :uploaded, :accepted,
      user: user_with_not_enough_rejected,
      anime_video: video_4
  end
  let!(:report_4_2) do
    create :anime_video_report, :uploaded, :accepted,
      user: user_with_not_enough_rejected,
      anime_video: video_4
  end
  let!(:report_4_3) do
    create :anime_video_report, :uploaded, :rejected,
      user: user_with_not_enough_rejected,
      anime_video: video_4
  end
  let!(:report_4_4) do
    create :anime_video_report, :broken, :accepted, anime_video: video_4
  end

  let(:user_with_not_enough_rejected_and_enough_reported) { build_stubbed :user }
  let(:video_5) { create :anime_video }
  let!(:report_5_1) do
    create :anime_video_report, :uploaded, :accepted,
      user: user_with_not_enough_rejected_and_enough_reported,
      anime_video: video_5
  end
  let!(:report_5_2) do
    create :anime_video_report, :uploaded, :accepted,
      user: user_with_not_enough_rejected_and_enough_reported,
      anime_video: video_5
  end
  let!(:report_5_3) do
    create :anime_video_report, :uploaded, :rejected,
      user: user_with_not_enough_rejected_and_enough_reported,
      anime_video: video_5
  end
  let!(:report_5_4) do
    create :anime_video_report, %i[wrong other].sample, :accepted, anime_video: video_5
  end

  before do
    stub_const 'AnimeOnline::ResponsibleUploaders::UPLOADS_TO_TRUST', 2
    stub_const 'AnimeOnline::ResponsibleUploaders::TRUST_THRESHOLD', 0.6
  end

  it do
    is_expected.to eq [
      user_enough_accepted.id,
      user_with_not_enough_rejected.id
    ]
  end
end
