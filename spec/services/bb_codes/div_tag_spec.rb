describe BbCodes::DivTag do
  let(:tag) { BbCodes::DivTag.instance }
  subject { tag.format text }

  context 'no class' do
    let(:text) { '[div]test[/div]' }
    it { is_expected.to eq '<div>test</div>' }
  end

  context 'single' do
    let(:text) { '[div=aaa bb-cd_e]test[/div]' }
    it { is_expected.to eq '<div class="aaa bb-cd_e">test</div>' }
  end

  context 'nested' do
    let(:text) { '[div=cc-2a][div=c-column]test[/div][/div]' }
    it do
      is_expected.to eq(
        '<div class="cc-2a"><div class="c-column">test</div></div>'
      )
    end
  end

  describe 'new lines cleanup' do
    let(:text) { "\n\n[div=cc-2]\n\n[div=c-column]\n\ntest\n\n[/div]\n\n[/div]\n\n" }
    it do
      is_expected.to eq(
        "\n<div class=\"cc-2\">\n<div class=\"c-column\">\ntest\n</div>\n</div>\n"
      )
    end
  end

  context 'unbalanced tags' do
    let(:text) { '[div=cc-2a][div=c-column]test[/div]' }
    it { is_expected.to eq text }
  end
end
