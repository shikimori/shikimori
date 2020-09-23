describe Styles::Download, :vcr do
  subject { described_class.call url }
  let(:url) { 'https://thiaya.github.io/1/shi.Modern.css' }

  it { is_expected.to eq ' x eval ' }

  context 'bad content' do
    let(:url) { 'https://i.imgur.com/ywBxdCN.png' }
    it { is_expected.to eq '' }
  end
end
