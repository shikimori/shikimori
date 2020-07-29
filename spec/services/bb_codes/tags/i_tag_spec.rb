describe BbCodes::Tags::ITag do
  subject { described_class.instance.format text }
  let(:text) { '[i]test[/i]' }
  it { is_expected.to eq '<em>test</em>' }
end
