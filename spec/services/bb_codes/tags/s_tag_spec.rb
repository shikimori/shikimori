describe BbCodes::Tags::STag do
  subject { described_class.instance.format text }
  let(:text) { '[s]test[/s]' }
  it { is_expected.to eq '<del>test</del>' }
end
