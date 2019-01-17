describe Coubs::Request, :vcr do
  subject { described_class.call tag, page }
  let(:page) { 1 }

  context 'common tags' do
    let(:tag) { 'edm' }

    it do
      is_expected.to have(10).items
      expect(subject.first).to be_kind_of Coub::Entry
      expect(subject.first).to have_attributes(
        player_url: 'https://coub.com/embed/1m6oy1',
        image_url: 'https://coubsecure-s.akamaihd.net/get/b127/p/coub/simple/cw_image/0bb7cf8d2ed/bac412830fc4b47318ca2/med_1547753932_00032.jpg',
        categories: %w[dance],
        tags: ['girls dancing', 'bang', 'edm shufflers', 'dance', 'dancers', 'vanesa', 'hot cutting shapes', 'shapes', 'e.cruz', 'vansecoo', 'elena cruz', 'violins space', 'house msuic', 'edm', 'cutting shapes']
      )
    end
  end

  context 'tag with non url symbols' do
    let(:tag) { 'girlfriend (kari)' }

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

  context 'missing tag' do
    let(:tag) { 'macross_frontier' }
    it { is_expected.to eq [] }
  end
end
