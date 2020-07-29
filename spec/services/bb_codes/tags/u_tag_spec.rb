describe BbCodes::Tags::UTag do
  subject { described_class.instance.format text }
  let(:text) { '[u]test[/u]' }
  it { is_expected.to eq '<u>test</u>' }
end
