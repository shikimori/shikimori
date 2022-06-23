describe Proxies::Check, :vcr do
  subject { described_class.call proxy: proxy }

  context 'working proxy' do
    let(:proxy) { Proxy.new ip: '51.158.169.52', port: 29976, protocol: :http }
    it { is_expected.to eq true }
  end

  context 'not transparent proxy' do
    let(:proxy) { Proxy.new ip: '51.158.169.52', port: 29976, protocol: :http }
    it { is_expected.to eq false }
  end
end
