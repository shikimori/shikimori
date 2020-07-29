describe BbCodes::Tags::BTag do
  subject { described_class.instance.format text }
  let(:text) { '[b]test[/b]' }
  it { is_expected.to eq '<strong>test</strong>' }
end
