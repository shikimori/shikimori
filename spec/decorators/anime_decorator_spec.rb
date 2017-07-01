describe AnimeDecorator do
  subject(:decorator) { anime.decorate }
  let(:anime) { build_stubbed :anime, id: id }
  let(:id) { 1 }

  describe '#licensed?' do
    it { is_expected.to_not be_licensed }

    context 'daisuki' do
      let(:id) { Copyright::DAISUKI_COPYRIGHTED.sample }
      it { is_expected.to_not be_licensed }
    end

    context 'istari' do
      let(:id) { Copyright::IVI_RU_COPYRIGHTED.sample }
      it { is_expected.to be_licensed }
    end

    context 'istari' do
      let(:id) { Copyright::ISTARI_COPYRIGHTED.sample }
      it { is_expected.to be_licensed }
    end
  end
end
