describe BbCodes::Tags::CenterTag do
  subject { described_class.instance.format text }
  let(:text) { '[center]test[/center]' }
  it { is_expected.to eq '<center>test</center>' }
end
