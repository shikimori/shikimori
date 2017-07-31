describe Ad do
  subject(:ad) { Ad.new width, height }

  before do
    allow(ad.h).to receive(:params).and_return params
    allow(ad.h).to receive(:ru_host?).and_return is_ru_host
    allow(ad.h).to receive(:shikimori?).and_return is_shikimori
    allow(ad.h).to receive(:current_user).and_return user
  end

  let(:params) { { controller: 'anime' } }
  let(:is_ru_host) { true }
  let(:is_shikimori) { true }
  let(:width) { 240 }
  let(:height) { 400 }
  let(:user) { nil }

  describe '#allowed?' do
    context 'no user' do
      it { is_expected.to be_allowed }
    end

    context 'user' do
      let(:user) { build_stubbed :user, id: 9_876_543 }
      it { is_expected.to be_allowed }
    end

    context 'admin' do
      let(:user) { build_stubbed :user, :admin }
      it { is_expected.to be_allowed }
    end

    context 'moderator' do
      let(:user) { build_stubbed :user, :versions_moderator }
      it { is_expected.to_not be_allowed }
    end
  end

  describe '#html' do
    context 'advertur' do
      let(:is_shikimori) { false }
      it do
        expect(ad.html).to include '<div class="b-spnsrs_block_1">'
        expect(ad.html).to include '<iframe src'
        expect(ad.html).to include "width='240px' height='400px'"
      end
    end

    context 'yandex_direct' do
      it do
        expect(ad.html).to include '<div class="b-spnsrs_block_1">'
        expect(ad.html).to include "<div id='#{ad.send :yandex_direct_node_id}'></div>"
      end
    end
  end

  describe '#type' do
    before { allow(ad).to receive(:yandex_direct?).and_return is_yandex_direct }

    context 'yandex_direct' do
      let(:is_yandex_direct) { true }
      it { expect(ad.type).to eq :yandex_direct }
    end

    context 'advertur' do
      let(:is_yandex_direct) { false }
      it { expect(ad.type).to eq :advertur }
    end
  end

  describe '#yandex_direct?' do
    it { is_expected.to be_yandex_direct }

    context 'not shikimori' do
      let(:is_shikimori) { false }
      it { is_expected.to_not be_yandex_direct }
    end

    context 'not ru_host' do
      let(:is_ru_host) { false }
      it { is_expected.to_not be_yandex_direct }
    end

    context 'not block_1' do
      let(:width) { 728 }
      let(:height) { 90 }
      it { is_expected.to_not be_yandex_direct }
    end
  end

  describe '#advertur_id' do
    subject { ad.send :advertur_id }

    context 'shikimori' do
      let(:is_shikimori) { true }

      context '240x400' do
        let(:width) { 240 }
        let(:height) { 400 }
        it { is_expected.to eq Ad::ADVERTUR_IDS[:block_1][0] }
      end

      context '728x90' do
        let(:width) { 728 }
        let(:height) { 90 }
        it { is_expected.to eq Ad::ADVERTUR_IDS[:block_2][0] }
      end

      context '300x250' do
        let(:width) { 300 }
        let(:height) { 250 }
        it { is_expected.to eq Ad::ADVERTUR_IDS[:block_3][0] }
      end

      context 'bad size' do
        let(:width) { 728 }
        let(:height) { 91 }
        it { expect { subject }.to raise_error ArgumentError, Ad::ERROR }
      end
    end

    context 'anime online' do
      let(:is_shikimori) { false }

      context '240x400' do
        let(:width) { 240 }
        let(:height) { 400 }
        it { is_expected.to eq Ad::ADVERTUR_IDS[:block_1][1] }
      end

      context '728x90' do
        let(:width) { 728 }
        let(:height) { 90 }
        it { is_expected.to eq Ad::ADVERTUR_IDS[:block_2][1] }
      end

      context '300x250' do
        let(:width) { 300 }
        let(:height) { 250 }
        it { expect { subject }.to raise_error ArgumentError, Ad::ERROR }
      end

      context 'bad size' do
        let(:width) { 728 }
        let(:height) { 91 }
        it { expect { subject }.to raise_error ArgumentError, Ad::ERROR }
      end
    end
  end

  describe '#yandex_direct_id' do
    it { expect(ad.send :yandex_direct_id).to eq Ad::YANDEX_DIRECT_IDS[:default] }
  end

  describe '#yandex_direct_node_id' do
    it { expect(ad.send :yandex_direct_node_id).to eq :block_1_yd }
  end

  describe '#advertur_url' do
    it do
      expect(ad.send :advertur_url).to eq(
        "//test.host/spnsrs/#{ad.send :advertur_id}"\
          "?container_class=#{ad.container_class}&height=400&width=240"
      )
    end
  end

  describe '#container_class' do
    before { allow(ad).to receive(:yandex_direct?).and_return is_yandex_direct }

    context 'yandex_direct' do
      let(:is_yandex_direct) { true }
      it { expect(ad.container_class).to eq 'spnsrs_block_1_240_400' }
    end

    context 'advertur' do
      let(:is_yandex_direct) { false }
      it { expect(ad.container_class).to eq 'spnsrs_block_1_240_400' }
    end
  end
end
