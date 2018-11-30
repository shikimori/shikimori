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
  let!(:report_4_1) { create :anime_video_report, :uploaded, :accepted, user: user_with_not_enough_rejected }
  let!(:report_4_2) { create :anime_video_report, :uploaded, :accepted, user: user_with_not_enough_rejected }
  let!(:report_4_3) { create :anime_video_report, :uploaded, :rejected, user: user_with_not_enough_rejected }

  before do
    stub_const 'AnimeOnline::ResponsibleUploaders::UPLOADS_TO_TRUST', 2
    stub_const 'AnimeOnline::ResponsibleUploaders::TRUST_THRESHOLD', 0.6
  end

  it { is_expected.to eq [user_enough_accepted.id, user_with_not_enough_rejected.id] }
end
