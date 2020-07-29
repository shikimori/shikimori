describe BbCodes::Tags::SolidTag do
  subject { described_class.instance.format text }
  let(:text) { '[solid]test[/solid]' }
  it { is_expected.to eq '<div class="solid">test</div>' }
end
