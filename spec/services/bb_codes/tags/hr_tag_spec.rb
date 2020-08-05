describe BbCodes::Tags::HrTag do
  subject { described_class.instance.format text }
  let(:text) { "[hr][hr]\n" }
  it { is_expected.to eq '<hr><hr>' }
end
