describe Coubs::Request, :vcr do
  subject { described_class.call tag, page }
  let(:page) { 1 }

  context 'common tags' do
    let(:tag) { 'edm' }

    it do
      is_expected.to have(10).items
      expect(subject.first).to be_kind_of Coub::Entry
      expect(subject.first.to_h).to eq(
        permalink: '1m6oy1',
        image_template: 'https://coubsecure-s.akamaihd.net/get/b127/p/coub/simple/cw_image/0bb7cf8d2ed/bac412830fc4b47318ca2/%{version}_1547753932_00032.jpg',
        categories: %w[dance],
        tags: ['girls dancing', 'bang', 'edm shufflers', 'dance', 'dancers', 'vanesa', 'hot cutting shapes', 'shapes', 'e.cruz', 'vansecoo', 'elena cruz', 'violins space', 'house msuic', 'edm', 'cutting shapes'],
        title: 'Violins Space',
        author: {
          avatar_template: 'https://coubsecure-s.akamaihd.net/get/b130/p/channel/cw_avatar/185f279738f/6c45a782d5776c135816d/%{version}_1546077566_cropped.jpeg',
          name: 'Cutting Shapes',
          permalink: 'cutting-shapes'
        },
        recoubed_permalink: nil
      )
    end
  end

  context 'tag with non url symbols' do
    let(:tag) { 'girlfriend (kari)' }

    it do
      is_expected.to have(1).item
      expect(subject.first).to be_kind_of Coub::Entry
      expect(subject.first.to_h).to eq(
        permalink: 'dcxm6',
        image_template: 'https://coubsecure-s.akamaihd.net/get/b57/p/coub/simple/cw_image/f7540dfe398/de96a2d8221af8702ebae/%{version}_1467728423_00038.jpg',
        categories: [],
        tags: ['animewebm', 'webm', 'girlfriend (kari)', 'anime', 'аниме'],
        title: '#Webm #AnimeWebm',
        author: {
          avatar_template: 'https://coubsecure-s.akamaihd.net/get/b118/p/channel/cw_avatar/e9dca0111ae/834df4f8093c65308570f/%{version}_1474495387_cropped.jpeg',
          name: 'DimanVip',
          permalink: 'dimanvip'
        },
        recoubed_permalink: nil
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
