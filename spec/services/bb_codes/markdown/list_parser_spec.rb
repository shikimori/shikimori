describe BbCodes::Markdown::ListParser do
  subject { described_class.instance.format text }

  context 'broken samples' do
    let(:text) { ['-a', ' -a', ' - a'].sample }
    it { is_expected.to eq text }
  end

  context 'single line' do
    before do
      allow_any_instance_of(BbCodes::Markdown::ListParserState)
        .to receive(:to_html)
        .and_return html
    end
    let(:text) { ['- a', '+ a', '* a'].sample }
    let(:html) { 'zxc' }
    it { is_expected.to eq html }
  end
end
