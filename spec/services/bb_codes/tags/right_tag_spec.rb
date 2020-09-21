describe BbCodes::Tags::RightTag do
  subject { described_class.instance.format text }
  let(:text) { '[right]test[/right]' }
  it { is_expected.to eq '<div class="right-text">test</div>' }

  context 'new lines' do
    let(:text) do
      [
        "[right]\ntest[/right]",
        "[right]test\n[/right]",
        "[right]test[/right]\n",
        "[right]\ntest\n[/right]\n"
      ].sample
    end
    it { is_expected.to eq '<div class="right-text">test</div>' }
  end
end
