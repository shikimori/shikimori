describe Network::FaradayGet, :vcr do
  subject(:response) { Network::FaradayGet.call url }
  let(:url) { 'http://ya.ru' }
  it { expect(response.status).to eq 200 }
end
