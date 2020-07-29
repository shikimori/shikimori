describe BbCodes::Tags::HrTag do
  subject { described_class.instance.format text }
  let(:text) { '[hr][hr]' + ["\r\n", "\r", "\n", '<br>'].sample }
  it { is_expected.to eq '<hr><hr>' }
end
