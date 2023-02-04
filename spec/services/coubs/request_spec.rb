describe Coubs::Request, :vcr do
  subject { described_class.call tag, page }
  let(:page) { 1 }

  context 'common tags' do
    let(:tag) { 'edm' }

    it do
      is_expected.to have(described_class::PER_PAGE).items
      expect(subject.first).to be_kind_of Coub::Entry
      expect(subject.first.to_h).to eq(
        permalink: '51pzi',
        image_template: 'https://coubsecure-s.akamaihd.net/get/b29/p/coub/simple/cw_image/728221c44fe/eb9d518721913a927b6ca/%{version}_1424137252_00021.jpg', # rubocop:disable Style/FormatStringToken
        categories: %w[animals-pets],
        tags: ['edm', 'grime', 'dubstep', 'house', 'techno', 'bass', 'cat', 'rave', 'circly circles', '3d mapping', 'projection', 'rave cat', 'ravecat'],
        title: 'ravecat',
        author: {
          avatar_template: 'https://coubsecure-s.akamaihd.net/get/b126/p/channel/cw_avatar/e97301ea36f/b8872d6565437a8ff7245/%{version}_1474683267_download__9_.jpeg', # rubocop:disable Style/FormatStringToken
          name: '○)⃝⃝)⃝⃝○○.⃝.⃝○⃝○⃝○○⃝⃝))⃝⃝',
          permalink: 'circlycircles'
        },
        recoubed_permalink: nil,
        created_at: Time.zone.parse('2015-02-17T01:40:28Z')
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
        image_template: 'https://coubsecure-s.akamaihd.net/get/b57/p/coub/simple/cw_image/f7540dfe398/de96a2d8221af8702ebae/%{version}_1467728423_00038.jpg', # rubocop:disable Style/FormatStringToken
        categories: [],
        tags: ['animewebm', 'webm', 'girlfriend (kari)', 'anime', 'аниме'],
        title: '#Webm #AnimeWebm',
        author: {
          avatar_template: 'https://coubsecure-s.akamaihd.net/get/b118/p/channel/cw_avatar/e9dca0111ae/834df4f8093c65308570f/%{version}_1474495387_cropped.jpeg', # rubocop:disable Style/FormatStringToken
          name: 'DimanVip',
          permalink: 'dimanvip'
        },
        recoubed_permalink: nil,
        created_at: Time.zone.parse('2016-07-05T14:18:43Z')
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

  context 'infinite loop' do
    let(:tag) { 'zxc' }
    let(:page) { 1000 }
    it { expect { subject }.to raise_error 'infinite loop' }
  end
end
