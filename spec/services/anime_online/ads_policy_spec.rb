describe AnimeOnline::AdsPolicy do
  let(:policy) { AnimeOnline::AdsPolicy }

  describe 'is_viewed?' do
    subject { policy.is_viewed? host, user }
    let(:guest_user) { build :user, id: User::GuestID }
    let(:trust_user) { build :user, id: 11496 }
    let(:simple_user) { build :user, id: 444 }

    context 'host_play' do
      let(:host) { AnimeOnlineDomain::HOST_PLAY }

      context 'guest' do
        let(:user) { guest_user }
        it { should be_truthy }
      end

      context 'trust' do
        let(:user) { trust_user }
        it { should be_falsy }
      end

      context 'simple' do
        let(:user) { simple_user }
        it { should be_truthy }
      end

      context 'nil' do
        let(:user) { nil }
        it { should be_truthy }
      end
    end

    context 'xhost_play' do
      let(:host) { AnimeOnlineDomain::HOST_XPLAY }

      context 'guest' do
        let(:user) { guest_user }
        it { should be_falsy }
      end

      context 'trust' do
        let(:user) { trust_user }
        it { should be_falsy }
      end

      context 'simple' do
        let(:user) { simple_user }
        it { should be_falsy }
      end
    end
  end
end
