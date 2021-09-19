describe AdsPolicy do
  subject(:policy) do
    AdsPolicy.new(
      ad_provider: ad_provider,
      user: user,
      is_ru_host: is_ru_host,
      is_disabled: is_disabled
    )
  end

  let(:ad_provider) { Types::Ad::Provider.values.sample }
  let(:user) { nil }
  let(:is_ru_host) { true }
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
          critique_moderator
          version_moderator
          version_texts_moderator
          version_fansub_moderator
          trusted_version_changer
          retired_moderator
        ].sample
      end

      context 'not special' do
        let(:ad_provider) do
          Types::Ad::Provider.values - [Types::Ad::Provider[:special]]
        end
        it { is_expected.to_not be_allowed }
      end

      context 'special' do
        let(:ad_provider) { Types::Ad::Provider[:special] }
        it { is_expected.to be_allowed }
      end
    end
  end
end
