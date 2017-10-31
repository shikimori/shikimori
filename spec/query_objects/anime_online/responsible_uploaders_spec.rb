describe AnimeOnline::ResponsibleUploaders do
  subject { described_class.call }

  let(:user_enough_accepted) { build_stubbed :user }
  let!(:report_1_1) { create :anime_video_report, :uploaded, :accepted, user: user_enough_accepted }
  let!(:report_1_2) { create :anime_video_report, :uploaded, :accepted, user: user_enough_accepted }

  let(:user_not_enough_accepted) { build_stubbed :user }
  let!(:report_2_1) { create :anime_video_report, :uploaded, :accepted, user: user_not_enough_accepted }

  let(:user_with_rejected) { build_stubbed :user }
  let!(:report_3_1) { create :anime_video_report, :uploaded, :accepted, user: user_with_rejected }
  let!(:report_3_2) { create :anime_video_report, :uploaded, :accepted, user: user_with_rejected }
  let!(:report_3_3) { create :anime_video_report, :uploaded, :rejected, user: user_with_rejected }

  before { stub_const 'AnimeOnline::ResponsibleUploaders::UPLOADS_TO_TRUST', 2 }

  it { is_expected.to eq [user_enough_accepted.id] }
end
