describe Network::FaradayGet, :vcr do
  subject(:response) { Network::FaradayGet.call url }

  context 'valid url' do
    let(:url) { 'http://ya.ru' }
    it { expect(response.status).to eq 200 }
  end

  context 'bad url' do
    let(:url) { 'http://ya.r' }
    it { expect(response).to be_nil }
  end
end
