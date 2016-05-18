describe GeoipAccess do
  let(:service) { GeoipAccess.instance }
  before { allow(service).to receive(:_stub_test).and_return false }
  before { allow(service).to receive(:ask_geoip).with(ip).and_return country_code }

  let(:ip) { '176.212.217.219' }
  let(:country_code) { 'RU' }

  describe '#safe_ip' do
    let(:ip) { 'nbvmnasd$#%^&*176.212.217.219/,mnbvc' }
    it { expect(service.safe_ip ip).to eq '176.212.217.219' }
  end

  describe '#country_code' do
    it { expect(service.country_code ip).to eq 'RU' }
  end

  describe '#allowed?' do
    context 'RU' do
      it { expect(service.allowed? ip).to be true }
    end

    context 'US' do
      let(:ip) { '176.212.217.220' }
      let(:country_code) { 'US' }
      it { expect(service.allowed? ip).to be false }
    end
  end
end
