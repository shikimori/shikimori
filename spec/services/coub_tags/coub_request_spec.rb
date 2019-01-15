describe CoubTags::CoubRequest, :vcr do
  subject { described_class.call tag, page }

  context 'common tags' do
    let(:tag) { 'edm' }
    let(:page) { 1 }

    it do
      is_expected.to have(10).items
      expect(subject.first).to be_kind_of Coub::Entry
      expect(subject.first).to have_attributes(
        player_url: 'https://coub.com/embed/1m1qqh',
        image_url: 'https://coubsecure-s.akamaihd.net/get/b180/p/coub/simple/cw_image/8ec5aa13821/ca7605128a3f5568945cc/med_1547580310_00032.jpg',
        categories: %w[dance],
        tags: ['umf', 'ultra', 'dancers', 'edm coubs', 'edm', 'progressive house music', 'progressive house', 'house music', 'c.k - into the night (original mix)', 'c.k', 'into the night', 'dance', 'djs', 'gogo dancers']
      )
    end
  end

  context 'tag with non url symbols' do
    let(:tag) { 'girlfriend (kari)' }
    let(:page) { 1 }

    it do
      is_expected.to have(1).item
      expect(subject.first).to be_kind_of Coub::Entry
      expect(subject.first).to have_attributes(
        player_url: 'https://coub.com/embed/dcxm6',
        image_url: 'https://coubsecure-s.akamaihd.net/get/b57/p/coub/simple/cw_image/f7540dfe398/de96a2d8221af8702ebae/med_1467728423_00038.jpg',
        categories: [],
        tags: ['animewebm', 'webm', 'girlfriend (kari)', 'anime', 'аниме']
      )
    end

    context 'network error' do
      before { allow(OpenURI).to receive(:open_uri).and_raise Timeout::Error }
      it { is_expected.to eq nil }
    end
  end
end
