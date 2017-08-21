describe AdsPolicy do
  subject(:policy) do
    AdsPolicy.new(
      is_ru_host: is_ru_host,
      is_shikimori: is_shikimori,
      ad_provider: ad_provider,
      user_id: user_id,
      is_istari_shown: is_istari_shown
    )
  end

  let(:is_ru_host) { true }
  let(:is_shikimori) { true }
  let(:ad_provider) { Types::Ad::Provider.values.sample }
  let(:user_id) { nil }
  let(:is_istari_shown) { false }

  it { is_expected.to be_allowed }

  context 'not ru_host' do
    let(:is_ru_host) { false }
    it { is_expected.to_not be_allowed }
  end

  describe 'user_id' do
    context 'user' do
      let(:user_id) { 9_876_543 }
      it { is_expected.to be_allowed }
    end

    context 'admin' do
      let(:user_id) { User::ADMINS.sample }
      it { is_expected.to be_allowed }
    end

    context 'moderator' do
      let(:user_id) { AdsPolicy::FORBIDDEN_USER_IDS.sample }
      it { is_expected.to_not be_allowed }
    end
  end

  describe 'is_shikimori & ad proider' do
    describe 'not shikimori & yandex_direct' do
      let(:is_shikimori) { false }
      let(:ad_provider) { Types::Ad::Provider[:yandex_direct] }
      it { is_expected.to_not be_allowed }
    end

    describe 'shikimori & yandex_direct' do
      let(:is_shikimori) { true }
      let(:ad_provider) { Types::Ad::Provider[:yandex_direct] }

      context 'istari not shown' do
        let(:is_istari_shown) { false }
        it { is_expected.to be_allowed }
      end

      context 'istari shown' do
        let(:is_istari_shown) { true }
        it { is_expected.to_not be_allowed }
      end
    end

    describe 'not shikimori & not yandex_direct' do
      let(:is_shikimori) { false }
      let(:ad_provider) { Types::Ad::Provider[:advertur] }
      it { is_expected.to be_allowed }
    end

    describe 'shikimori & not yandex_direct' do
      let(:is_shikimori) { true }
      let(:ad_provider) { Types::Ad::Provider[:advertur] }

      context 'istari not shown' do
        let(:is_istari_shown) { false }
        it { is_expected.to be_allowed }
      end

      context 'istari shown' do
        let(:is_istari_shown) { true }
        it { is_expected.to_not be_allowed }
      end
    end
  end
end
