describe Proxies::Check do
  before { allow(Proxy).to receive(:get).and_return content }
  subject! { described_class.call proxy: proxy, ips: ips }

  let(:ips) { ['140.100.100.101'] }
  let(:proxy) { Proxy.new ip: '51.158.169.52', port: 29976, protocol: :http }

  let(:content) do
    <<-TEXT
      127.0.0.1 | GET | /proxy_test | /proxy_test | /proxy_test | HTTP/1.0
      | HTTP/1.0 | https | 2001:bc8:182c:1f0f::1, 140.100.100.100 | shikimori.one
      | 140.100.100.100 | close | 2001:bc8:182c:1f0f::1 | cloudflare | gzip | NL
      | 6f09e339e9d1fa34-AMS | {"scheme":"https"} | Mozilla/5.0 (Windows NT 10.0;
      Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36
      | */* | shikimori.one | 443 |  |  | Unicorn 6.0.0 | /proxy_test |  test_passed
    TEXT
  end

  it do
    expect(Proxy).to have_received(:get).with(
      described_class::TEST_URL,
      timeout: described_class::TEST_TIMEOUT,
      proxy: proxy
    )
  end

  context 'anonymouse proxy' do
    it { is_expected.to eq true }
  end

  context 'non anonymouse proxy' do
    let(:ips) { ['140.100.100.100'] }
    it { is_expected.to eq false }
  end

  context 'broken proxy' do
    let(:content) { nil }
    it { is_expected.to eq false }
  end
end
