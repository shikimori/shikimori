describe GeoipAccess do
  let(:service) { described_class.instance }

  before do
    allow(service).to receive(:sng?).with(ip).and_call_original
    allow(service).to receive(:ask_geoip).with(ip).and_return country_code
  end

  let(:ip) { '176.212.217.219' }
  let(:country_code) { 'RU' }

  describe '#safe_ip' do
    let(:ip) { 'nbvmnasd$#%^&*176.212.217.219/,mnbvc' }
    it { expect(service.safe_ip ip).to eq '176.212.217.219' }
  end

  describe '#country_code' do
    it { expect(service.country_code ip).to eq 'RU' }
  end

  describe '#sng?' do
    subject { service.sng? ip }

    context 'RU' do
      it { is_expected.to be true }
    end

    context 'US' do
      let(:ip) { '176.212.217.220' }
      let(:country_code) { 'US' }
      it { is_expected.to be false }
    end
  end
end
