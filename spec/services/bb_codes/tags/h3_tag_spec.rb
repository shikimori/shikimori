describe BbCodes::Tags::H3Tag do
  subject { described_class.instance.format text }
  let(:text) { '[h3]test[/h3]' + ["\r\n", "\r", "\n", '<br>'].sample }
  it { is_expected.to eq '<h3>test</h3>' }
end
