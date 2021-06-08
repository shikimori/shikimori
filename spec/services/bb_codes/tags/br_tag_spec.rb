describe BbCodes::Tags::BrTag do
  subject { described_class.instance.format text }
  let(:text) { '[br]test' }
  it { is_expected.to eq '<br data-keep>test' }
end
