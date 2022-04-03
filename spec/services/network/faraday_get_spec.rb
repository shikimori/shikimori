describe Network::FaradayGet, :vcr do
  subject(:response) { Network::FaradayGet.call url }
  let(:url) { 'http://ya.ru' }
  it { expect(response.status).to eq 200 }

  context 'redirect with /' do
    let(:url) { 'http://vk.com/video_ext.php?oid=-126822319&amp;id=456241214&hash=f899d33f4b0ee3a7' }
    it { expect(response.status).to eq 200 }
  end

  context 'redirect with relative path' do
    let(:url) { 'http://www.tbs.co.jp/anime/drivehead' }
    it { expect(response.status).to eq 200 }
  end

  context 'no url' do
    let(:url) { '' }
    it { expect(response).to be_nil }
  end

  context 'incorrect domain name' do
    let(:url) { '.vk.com/' }
    it { expect(response).to be_nil }
  end
end
