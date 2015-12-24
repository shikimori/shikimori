describe AnimeOnline::AdsPolicy do
  let(:policy) { AnimeOnline::AdsPolicy }

  describe 'show_ad?' do
    subject { policy.show_ad? host, user, anime }

    let(:guest_user) { build :user, id: User::GUEST_ID }
    let(:trust_user) { build :user, id: 11496 }
    let(:admin_user) { build :user, :admin }
    let(:simple_user) { build :user, id: 444 }
    let(:anime) { }

    context 'not banned by ivi' do
      let(:anime) { build_stubbed :anime }
      let(:host) { AnimeOnlineDomain::HOST_PLAY }
      let(:user) { guest_user }

      it { should eq true }
    end

    context 'banned by ivi' do
      let(:anime) { build_stubbed :anime, id: Copyright::IVI_RU_COPYRIGHTED.sample }
      let(:host) { AnimeOnlineDomain::HOST_PLAY }
      let(:user) { guest_user }

      it { should eq false }
    end

    context 'host_play' do
      let(:host) { AnimeOnlineDomain::HOST_PLAY }

      context 'guest' do
        let(:user) { guest_user }
        it { should eq true }
      end

      context 'trust' do
        let(:user) { trust_user }
        it { should eq false }
      end

      context 'admin' do
        let(:user) { admin_user }
        it { should eq true }
      end

      context 'simple' do
        let(:user) { simple_user }
        it { should eq true }
      end

      context 'nil' do
        let(:user) { nil }
        it { should eq true }
      end
    end

    context 'xhost_play' do
      let(:host) { AnimeOnlineDomain::HOST_XPLAY }

      context 'guest' do
        let(:user) { guest_user }
        it { should eq false }
      end

      context 'trust' do
        let(:user) { trust_user }
        it { should eq false }
      end

      context 'simple' do
        let(:user) { simple_user }
        it { should eq false }
      end
    end
  end
end
