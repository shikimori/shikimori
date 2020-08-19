describe BbCodes::Markdown::ListQuoteParser do
  subject { described_class.instance.format text }
  let(:symbol) { ['-', '+', '*', '>', '&gt;'].sample }

  context 'broken samples' do
    let(:text) { ["#{symbol}a", " #{symbol}a", " #{symbol} a"].sample }
    it { is_expected.to eq text }
  end

  context 'single line' do
    before do
      allow_any_instance_of(BbCodes::Markdown::ListQuoteParserState)
        .to receive(:to_html)
        .and_return html
    end
    let(:text) { "q\n#{symbol} a\nw" }
    let(:html) { "zxc\n" }
    it { is_expected.to eq "q\n#{html}w" }
  end

  context 'multiline line' do
    before do
      allow_any_instance_of(BbCodes::Markdown::ListQuoteParserState)
        .to receive(:to_html)
        .and_return html
    end
    let(:text) { "q\n#{symbol} a\n#{symbol} a" }
    let(:html) { "zxc\n" }
    it { is_expected.to eq "q\n#{html}" }

    context 'moves through inner tags' do
      let(:text) { "q\n#{symbol} z [spoiler=x]x\nx[/spoiler]\n#{symbol} c" }
      it { is_expected.to eq "q\n#{html}" }
    end
  end
end
