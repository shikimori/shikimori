describe Ad do
  let(:ad) { Ad.new width, height }
  before { allow(ad.h).to receive(:anime_online?).and_return is_anime_online }

  let(:is_anime_online) { false }
  let(:width) { 240 }
  let(:height) { 400 }

  describe '#id' do
    subject { ad.id }

    context 'shikimori' do
      let(:is_anime_online) { false }

      context '240x400' do
        let(:width) { 240 }
        let(:height) { 400 }
        it { is_expected.to eq Ad::IDS[:block_1][0] }
      end

      context '728x90' do
        let(:width) { 728 }
        let(:height) { 90 }
        it { is_expected.to eq Ad::IDS[:block_2][0] }
      end

      context '300x250' do
        let(:width) { 300 }
        let(:height) { 250 }
        it { is_expected.to eq Ad::IDS[:block_3][0] }
      end

      context 'bad size' do
        let(:width) { 728 }
        let(:height) { 91 }
        it { expect{subject}.to raise_error RuntimeError }
      end
    end

    context 'anime online' do
      let(:is_anime_online) { true }

      context '240x400' do
        let(:width) { 240 }
        let(:height) { 400 }
        it { is_expected.to eq Ad::IDS[:block_1][1] }
      end

      context '728x90' do
        let(:width) { 728 }
        let(:height) { 90 }
        it { is_expected.to eq Ad::IDS[:block_2][1] }
      end

      context '300x250' do
        let(:width) { 300 }
        let(:height) { 250 }
        it { expect{subject}.to raise_error RuntimeError }
      end

      context 'bad size' do
        let(:width) { 728 }
        let(:height) { 91 }
        it { expect{subject}.to raise_error RuntimeError }
      end
    end
  end

  describe '#url' do
    it { expect(ad.url).to eq "http://test.host/sponsors/#{ad.id}?container_class=sponsors_#{ad.id}_240_400&height=400&width=240" }
  end

  describe '#container_class' do
    it { expect(ad.container_class).to eq 'sponsors_92129_240_400' }
  end
end
