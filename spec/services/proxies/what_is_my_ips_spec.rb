describe Proxies::WhatIsMyIps, :vcr do
  subject { described_class.call }
  it { is_expected.to eq %w[123.345.789.123 234.456.678.189] }
end
