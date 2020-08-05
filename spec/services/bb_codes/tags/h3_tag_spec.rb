describe BbCodes::Tags::H3Tag do
  subject { described_class.instance.format text }
  let(:text) { "[h3]test[/h3]\n" }
  it { is_expected.to eq '<h3>test</h3>' }
end
