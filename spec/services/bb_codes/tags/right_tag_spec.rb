describe BbCodes::Tags::RightTag do
  subject { described_class.instance.format text }
  let(:text) { '[right]test[/right]' }
  it { is_expected.to eq '<div class="right-text">test</div>' }
end
