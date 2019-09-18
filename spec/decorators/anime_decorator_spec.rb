describe AnimeDecorator do
  subject(:decorator) { anime.decorate }
  let(:anime) { build_stubbed :anime, id: id }
  let(:id) { 1 }

  before { allow(decorator.h).to receive(:current_user).and_return user }
  let(:user) { nil }

  describe '#licensed?' do
    it { is_expected.to_not be_licensed }

    context 'istari' do
      let(:id) { Copyright::ISTARI_COPYRIGHTED.sample }
      # it { is_expected.to_not be_licensed }
      it { is_expected.to be_licensed }

      # context 'current user video_moderator or trusted_video_uploader' do
      #   let(:user) { build_stubbed :user, %i[video_moderator trusted_video_uploader].sample }
      #   it { is_expected.to_not be_licensed }
      #   # it { is_expected.to be_licensed }
      # end
    end
  end
end
