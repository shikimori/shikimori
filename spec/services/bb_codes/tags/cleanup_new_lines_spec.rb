describe BbCodes::Tags::CleanupNewLines do
  subject { described_class.call text, tag }

  context 'div' do
    let(:tag) { :div }

    context '\n\n<\div>' do
      let(:text) { "[div=cc-2][div]test\n\n[/div][/div]" }
      it { is_expected.to eq "[div=cc-2][div]test\n[/div][/div]" }
    end

    context '<div>\n\n' do
      let(:text) { "[div=c-column]\n\ntest[/div]" }
      it { is_expected.to eq "[div=c-column]\ntest[/div]" }
    end

    context '<\div>\n\n' do
      let(:text) { "[div=c-column]test[/div]\n\n" }
      it { is_expected.to eq "[div=c-column]test[/div]\n" }
    end

    context '\n\n<\div>' do
      let(:text) { "[div=c-column]test\n\n[/div]" }
      it { is_expected.to eq "[div=c-column]test\n[/div]" }
    end

    describe 'cleanups do not overlap with each other' do
      let(:text) { "[div=cc-2]\n\n[div=c-column]\n\ntest\n\n[/div]\n\n[/div]\n\n" }
      it { is_expected.to eq "[div=cc-2]\n[div=c-column]\ntest\n[/div]\n[/div]\n" }
    end
  end

  context 'quote' do
    let(:tag) { :quote }
    let(:text) { "\n\n[quote]\n\n[quote=cc6104643;1;c]\n\ntest\n\n[/quote]\n\n[/quote]\n\n" }
    it { is_expected.to eq "\n\n[quote]\n[quote=cc6104643;1;c]\ntest\n[/quote]\n[/quote]\n" }
  end

  context 'div + quote' do
    let(:tag) { described_class::TAGS }
    let(:text) { "\n\n[quote]\n\n[div=c-column]\n\ntest\n\n[/div]\n\n[/quote]\n\n" }
    it { is_expected.to eq "\n\n[quote]\n[div=c-column]\ntest\n[/div]\n[/quote]\n" }

    context 'sample' do
      let(:text) { "\n\n[div]test[/div]" }
      it { is_expected.to eq text }
    end
  end
end
