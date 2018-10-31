describe Neko::Duration do
  subject { described_class.call anime }

  before { allow(Neko::Episodes).to receive(:call).with(anime).and_return 9 }
  let(:anime) { build :anime, duration: 10 }

  it { is_expected.to eq 90 }
end
