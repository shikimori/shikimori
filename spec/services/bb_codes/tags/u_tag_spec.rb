describe BbCodes::Tags::UTag do
  let(:tag) { described_class.instance }
  subject { tag.format '[u]test[/u]' }
  it { is_expected.to eq '<u>test</u>' }
end
