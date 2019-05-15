describe AdsPolicy do
  subject(:policy) do
    AdsPolicy.new(
      is_ru_host: is_ru_host,
      is_clean_host: is_clean_host,
      is_shikimori: is_shikimori,
      ad_provider: ad_provider,
      user: user,
      is_disabled: is_disabled
    )
  end

  let(:is_ru_host) { true }
  let(:is_clean_host) { false }
  let(:is_shikimori) { true }
  let(:ad_provider) { Types::Ad::Provider.values.sample }
  let(:user) { nil }
  let(:is_disabled) { false }

  it { is_expected.to be_allowed }

  context 'is_disabled' do
    let(:is_disabled) { true }
    it { is_expected.to_not be_allowed }
  end

  context 'not ru_host' do
    let(:is_ru_host) { false }
    it { is_expected.to_not be_allowed }
  end

  context 'clean host' do
    let(:is_clean_host) { true }
    it { is_expected.to_not be_allowed }
  end

  describe 'user_id' do
    context 'user' do
      let(:user) { build :user, :user }
      it { is_expected.to be_allowed }
    end

    context 'admin' do
      let(:user) { build :user, :admin }
      it { is_expected.to be_allowed }
    end

    context 'moderator' do
      let(:user) do
        build :user, %i[
          forum_moderator
          review_moderator
          version_moderator
          video_moderator
          trusted_version_changer
          trusted_video_uploader
        ].sample
      end

      context 'not istari' do
        let(:ad_provider) do
          Types::Ad::Provider.values - [Types::Ad::Provider[:istari]]
        end
        it { is_expected.to_not be_allowed }
      end

      context 'istari' do
        let(:ad_provider) { Types::Ad::Provider[:istari] }
        it { is_expected.to be_allowed }
      end

      context 'special' do
        let(:ad_provider) { Types::Ad::Provider[:special] }
        it { is_expected.to be_allowed }
      end
    end
  end

  describe 'is_shikimori & ad_proider' do
    describe 'not shikimori & mainstream' do
      let(:is_shikimori) { false }
      let(:ad_provider) { Types::Ad::Provider[%i[yandex_direct mytarget].sample] }
      it { is_expected.to_not be_allowed }
    end

    describe 'shikimori & mainstream' do
      let(:is_shikimori) { true }
      let(:ad_provider) { Types::Ad::Provider[%i[yandex_direct mytarget].sample] }
      it { is_expected.to be_allowed }
    end

    describe 'not shikimori & not mainstream' do
      let(:is_shikimori) { false }
      let(:ad_provider) { Types::Ad::Provider[:advertur] }
      it { is_expected.to be_allowed }
    end

    describe 'shikimori & not mainstream' do
      let(:is_shikimori) { true }
      let(:ad_provider) { Types::Ad::Provider[:advertur] }
      it { is_expected.to be_allowed }
    end
  end
end
