describe BbCodes::Markdown::ListParserState do
  subject { described_class.new(text).to_html }

  context 'single line' do
    let(:text) { ['- a', '+ a', '* a'].sample }
    it { is_expected.to eq "<ul class='b-list'><li>a</li></ul>" }
  end

  context 'sample' do
    let(:text) { '- qwe' }
    it { is_expected.to eq "<ul class='b-list'><li>qwe</li></ul>" }
  end

  context 'sample' do
    let(:text) { "- qwe\n" }
    it { is_expected.to eq "<ul class='b-list'><li>qwe</li></ul>" }
  end

  # context 'item content on next line' do
  #   let(:text) { "- a\n  b" }
  #   it { is_expected.to eq "<ul class='b-list'><li>a\nb</li></ul>" }
  # end

  context 'content after' do
    let(:text) { "- a\nb" }
    it { is_expected.to eq "<ul class='b-list'><li>a</li></ul>b" }
  end

  context 'multiline', :focus do
    let(:text) { "- a\n- b" }
    it { is_expected.to eq "<ul class='b-list'><li>a</li><li>b</li></ul>" }
  end
end
