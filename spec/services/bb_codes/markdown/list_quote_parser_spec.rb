describe BbCodes::Markdown::ListQuoteParser do
  subject { described_class.instance.format text }
  let(:symbol) { ['-', '+', '*', '>', '&gt;'].sample }

  context 'broken samples' do
    let(:text) { ["#{symbol}a", " #{symbol}a", " #{symbol} a"].sample }
    it { is_expected.to eq text }
  end

  context 'single line' do
    before do
      allow(BbCodes::Markdown::ListQuoteParserState)
        .to receive(:new)
        .and_return parser_state
    end
    let(:parser_state) { double to_html: html }
    let(:text) { "q\n#{symbol} a\nw" }
    let(:html) { "zxc\n" }

    it do
      is_expected.to eq "q\n#{html}w"
      expect(BbCodes::Markdown::ListQuoteParserState)
        .to have_received(:new)
        .with "#{symbol} a\n"
    end

    context 'tags before' do
      let(:text) { "#{tag}#{symbol} a\nw" }
      let(:html) { "zxc\n" }
      let(:tag) { ['</div>', '</h2>', '</h3>', '</h4>'].sample }
      it do
        is_expected.to eq "#{tag}#{html}w"
        expect(BbCodes::Markdown::ListQuoteParserState)
          .to have_received(:new)
          .with "#{symbol} a\n"
      end
    end
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

    context 'traverses through multiline bbcodes' do
      let(:text) { "q\n#{symbol} z [spoiler=x]x\nx[/spoiler]\n#{symbol} c" }
      it { is_expected.to eq "q\n#{html}" }
    end

    context 'traverses through multiline bbcodes multiple times' do
      let(:text) { "q\n#{symbol} z [spoiler=x]x\nx[/spoiler][div]\n[/div]\n#{symbol} c" }
      it { is_expected.to eq "q\n#{html}" }
    end

    context 'does not traverse through new' do
      let(:text) { "q\n#{symbol} z\n[spoiler]zxc[/spoiler]" }
      it { is_expected.to eq "q\n#{html}[spoiler]zxc[/spoiler]" }
    end
  end
end
