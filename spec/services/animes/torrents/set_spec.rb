describe Animes::Torrents::Set do
  subject! { described_class.call anime, torrents }

  let(:anime) { build_stubbed :anime }
  let(:torrents) { 'zxc' }

  it { expect(Animes::Torrents::Get.call(anime)).to eq torrents }
end
