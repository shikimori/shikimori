describe BbCodes::Tags::SpanTag do
  subject { described_class.instance.format text }

  let(:text) { '[span]test[/span]' }
  it { is_expected.to eq '<span data-span>test</span>' }

  context 'class' do
    context 'single' do
      let(:text) { '[span=aaa]test[/span]' }
      it { is_expected.to eq '<span class="aaa" data-span>test</span>' }
    end

    context 'multiple' do
      let(:text) { '[span=aaa bb-cd_e]test[/span]' }
      it { is_expected.to eq '<span class="aaa bb-cd_e" data-span>test</span>' }
    end
  end

  context 'data-attribute' do
    context 'single' do
      context 'wo value' do
        let(:text) { '[span data-test]test[/span]' }
        it { is_expected.to eq '<span data-test data-span>test</span>' }
      end

      context 'with value' do
        let(:text) { '[span data-test=zxc]test[/span]' }
        it { is_expected.to eq '<span data-test=zxc data-span>test</span>' }
      end
    end

    context 'multiple' do
      let(:text) { '[span data-test data-fofo]test[/span]' }
      it { is_expected.to eq '<span data-test data-fofo data-span>test</span>' }
    end
  end

  context 'class + data-attribute' do
    let(:text) { '[span=aaa bb-cd_e data-test data-fofo]test[/span]' }
    it do
      is_expected.to eq(
        '<span class="aaa bb-cd_e" data-test data-fofo data-span>test</span>'
      )
    end
  end

  context 'nested' do
    let(:text) { '[span=cc-2a][span=c-column]test[/span][/span]' }
    it do
      is_expected.to eq(
        '<span class="cc-2a" data-span><span class="c-column" data-span>test</span></span>'
      )
    end
  end

  context 'cleanup classes' do
    let(:text) do
      "[span=aaa l-footer #{BbCodes::CleanupCssClass::FORBIDDEN_CSS_CLASSES.sample}]test[/span]"
    end
    it { is_expected.to eq '<span class="aaa" data-span>test</span>' }
  end

  context 'unbalanced tags' do
    let(:text) { '[span=cc-2a][span=c-column]test[/span]' }
    it { is_expected.to eq text }
  end
end
