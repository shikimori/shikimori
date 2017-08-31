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

  describe 'new lines' do
    let(:result) { '<div class="cc-2"><div class="c-column">test</div></div>' }
      # let(:text) { "[div=cc-2]\n\n[div=c-column]test\n\n[/div]\n\n[/div]\n\n" }

    context 'ending \n' do
      let(:text) { "[div=cc-2][div=c-column]test[/div][/div]\n\n" }
      it { is_expected.to eq result + "\n\n" }
    end

    context '<div>\n<div>' do
      let(:text) { "[div=cc-2]\n\n[div=c-column]test[/div][/div]" }
      it { is_expected.to eq result }
    end

    context '\n<\div>' do
      let(:text) { "[div=cc-2][div=c-column]test\n\n[/div][/div]" }
      it { is_expected.to eq result }
    end

    context '<\div>\n<\div>' do
      let(:text) { "[div=cc-2][div=c-column]test[/div]\n\n[/div]" }
      it { is_expected.to eq result }
    end

    context '<\div>\n<div>' do
      let(:text) { "[div=c-column]test[/div]\n\n[div=c-column]test[/div]" }
      it do
        is_expected.to eq(
          '<div class="c-column">test</div><div class="c-column">test</div>'
        )
      end
    end

    context '<div>\n' do
      let(:text) { "[div=c-column]\ntest[/div]" }
      it { is_expected.to eq '<div class="c-column">test</div>' }
    end

    context '<div>\n\n' do
      let(:text) { "[div=c-column]\n\ntest[/div]" }
      it { is_expected.to eq "<div class=\"c-column\">\ntest</div>" }
    end
  end

  context 'unbalanced tags' do
    let(:text) { '[div=cc-2a][div=c-column]test[/div]' }
    it { is_expected.to eq text }
  end
end
