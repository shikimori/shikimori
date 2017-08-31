describe BbCodes::DivTag do
  let(:tag) { BbCodes::DivTag.instance }
  subject { tag.format text }

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

  context 'unbalanced tags' do
    let(:text) { '[div=cc-2a][div=c-column]test[/div]' }
    it { is_expected.to eq text }
  end
end
