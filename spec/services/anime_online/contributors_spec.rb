describe AnimeOnline::Contributors do
  before { stub_const 'AnimeOnline::Contributors::UPLOAD_SCORE', 2 }
  let(:limit) { 20 }
  let(:is_adult) { nil }

  describe '.top' do
    subject { AnimeOnline::Contributors.top(limit, is_adult) }

    context 'empty' do
      it { is_expected.to be_empty }
    end

    context 'consider broken' do
      let(:user) { create :user, :user }
      let!(:report) { create :anime_video_report, :broken, :accepted, user: user }
      it { is_expected.to eq [user] }
    end

    context 'ignore rejected and pending broken reports' do
      let(:user) { create :user, :user }
      let!(:report_1) { create :anime_video_report, :broken, :rejected, user: user }
      let!(:report_2) { create :anime_video_report, :broken, :pending, user: user }
      it { is_expected.to be_empty }
    end

    context 'consider wrong' do
      let(:user) { create :user, :user }
      let!(:report) { create :anime_video_report, :wrong, :accepted, user: user }
      it { is_expected.to eq [user] }
    end

    context 'ignore rejected and pending wrong reports' do
      let(:user) { create :user, :user }
      let!(:report_1) { create :anime_video_report, :wrong, :rejected, user: user }
      let!(:report_2) { create :anime_video_report, :wrong, :pending, user: user }
      it { is_expected.to be_empty }
    end

    context 'consider uploaded' do
      let(:user) { create :user, :user }
      let!(:report) { create :anime_video_report, :uploaded, :accepted, user: user }
      it { is_expected.to eq [user] }
    end

    context 'ignore uploaded and pending broken reports' do
      let(:user) { create :user, :user }
      let!(:report_1) { create :anime_video_report, :uploaded, :rejected, user: user }
      let!(:report_2) { create :anime_video_report, :uploaded, :pending, user: user }
      it { is_expected.to be_empty }
    end

    context 'win by checking video' do
      let(:user_uploader) { create :user, :user }
      let(:user_checker) { create :user, :user }
      let!(:report_1u) { create :anime_video_report, :uploaded, :accepted, user: user_uploader }
      let!(:report_1c) { create :anime_video_report, :broken, :accepted, user: user_checker }
      let!(:report_2c) { create :anime_video_report, :broken, :accepted, user: user_checker }
      let!(:report_3c) { create :anime_video_report, :wrong, :accepted, user: user_checker }

      it { is_expected.to have(2).items }
      its(:first) { is_expected.to eq user_checker }
      its(:second) { is_expected.to eq user_uploader }
    end

    context 'win by uploading video' do
      let(:user_uploader) { create :user, :user }
      let(:user_checker) { create :user, :user }
      let!(:report_1u) { create :anime_video_report, :uploaded, :accepted, user: user_uploader }
      let!(:report_1c) { create :anime_video_report, :broken, :accepted, user: user_checker }

      it { is_expected.to have(2).items }
      its(:first) { is_expected.to eq user_uploader }
      its(:second) { is_expected.to eq user_checker }
    end

    context 'ignore guest' do
      let(:user) { create :user, :guest }
      let!(:report) { create :anime_video_report, :broken, :accepted, user: user }
      it { is_expected.to be_empty }
    end

    context 'limited' do
      let(:limit) { 1 }
      let(:user_1) { create :user, :user }
      let(:user_2) { create :user, :user }
      let!(:report_1) { create :anime_video_report, :uploaded, :accepted, user: user_1 }
      let!(:report_2) { create :anime_video_report, :uploaded, :accepted, user: user_2 }
      it { is_expected.to eq [user_1] }
    end

    context 'adult filter' do
      let(:anime_pg) { create :anime, :pg_13 }
      let(:anime_rx) { create :anime, :rx_hentai }

      let(:anime_video_pg) { create :anime_video, anime: anime_pg }
      let(:anime_video_rx) { create :anime_video, anime: anime_rx }

      let(:user_1) { create :user, :user }
      let(:user_2) { create :user, :user }
      let!(:report_1) { create :anime_video_report, :uploaded, :accepted, user: user_1, anime_video: anime_video_pg }
      let!(:report_2) { create :anime_video_report, :uploaded, :accepted, user: user_2, anime_video: anime_video_rx }

      context 'is_adult=true' do
        let(:is_adult) { true }
        it { is_expected.to eq [user_2] }
      end

      context 'is_adult=false' do
        let(:is_adult) { false }
        it { is_expected.to eq [user_1] }
      end
    end
  end
end
