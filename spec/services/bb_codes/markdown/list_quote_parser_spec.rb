describe BbCodes::Markdown::ListQuoteParser do
  subject { described_class.instance.format text }
  let(:symbol) { %w[- + * >].sample }

  context 'broken samples' do
    let(:text) { ["#{symbol}a", " #{symbol}a", " #{symbol} a"].sample }
    it { is_expected.to eq text }
  end

  context 'single line' do
    before do
      allow_any_instance_of(BbCodes::Markdown::ListQuoteParserState)
        .to receive(:call)
        .and_return html
    end
    let(:text) { "#{symbol} a" }
    let(:html) { 'zxc' }
    it { is_expected.to eq html }
  end
end
