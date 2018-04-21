describe Network::FaradayGet, :vcr do
  subject(:response) { Network::FaradayGet.call url }
  let(:url) { 'http://ya.ru' }
  it { expect(response.status).to eq 200 }

  context 'redirect with /' do
    let(:url) { 'http://vk.com/video_ext.php?oid=-126822319&amp;id=456241214&hash=f899d33f4b0ee3a7' }
    it { expect(response.status).to eq 200 }
  end
end
