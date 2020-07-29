describe BbCodes::Tags::PTag do
  subject { described_class.instance.format text }
  let(:text) { '[p]test[/p]' }
  it { is_expected.to eq '<div class="b-prgrph">test</div>' }
end
