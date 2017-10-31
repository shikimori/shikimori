describe AnimeOnline::UploaderPolicy do
  subject(:policy) { described_class.new user }
  let(:user) { seed :user }

  describe '#trusted?' do
    let(:user) { build_stubbed :user, role }

    before { stub_const 'AnimeOnline::ResponsibleUploaders::UPLOADS_TO_TRUST', 1 }

    context 'common user' do
      let(:role) { :user }
      it { is_expected.to_not be_trusted }
    end

    context 'trusted_video_uploader' do
      let(:role) { :trusted_video_uploader }
      it { is_expected.to be_trusted }
    end

    context 'responsible' do
      let(:role) { :user }
      let!(:report) { create :anime_video_report, :uploaded, :accepted, user: user }

      it { is_expected.to be_trusted }

      context 'not trusted' do
        let(:role) { :not_trusted_video_uploader }
        it { is_expected.to_not be_trusted }
      end
    end
  end
end
