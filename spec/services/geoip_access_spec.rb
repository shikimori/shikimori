describe GeoipAccess do
  let(:service) { described_class.instance }

  before do
    allow(service).to receive(:anime_online_allowed?).with(ip).and_call_original
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

  describe '#anime_online_allowed?' do
    subject { service.anime_online_allowed? ip }

    context 'RU' do
      it { is_expected.to be true }
    end

    context 'US' do
      let(:ip) { '176.212.217.220' }
      let(:country_code) { 'US' }
      it { is_expected.to be false }
    end
  end

  describe '#wakanim_allowed?' do
    subject { service.wakanim_allowed? ip }

    context 'RU' do
      it { is_expected.to be false }
    end

    context 'US' do
      let(:ip) { '176.212.217.220' }
      let(:country_code) { 'US' }
      it { is_expected.to be true }
    end

    context 'FR' do
      let(:ip) { '176.212.217.221' }
      let(:country_code) { 'FR' }
      it { is_expected.to be false }
    end

    context 'unknown' do
      let(:ip) { '176.212.217.222' }
      let(:country_code) { described_class::HZ }
      it { is_expected.to be false }
    end

    context 'JP' do
      let(:ip) { '176.212.217.223' }
      let(:country_code) { 'JP' }
      it { is_expected.to be false }
    end

    context 'UA' do
      let(:ip) { '176.212.217.224' }
      let(:country_code) { 'UA' }
      it { is_expected.to be true }
    end
  end
end
