describe BbCodes::EntryText do
  before do
    allow(BbCodes::CharactersNames).to receive(:call) { |text| text + 'c' }
  end

  subject! { described_class.call text, entry }
  let(:text) { '[[z]]' }

  context 'entry with characters' do
    let(:entry) { build :anime }

    it { is_expected.to eq '<div class="b-text_with_paragraphs">zc</div>' }
    it { is_expected.to be_html_safe }
  end

  context 'entry without characters' do
    let(:entry) { build :character }

    it { is_expected.to eq '<div class="b-text_with_paragraphs">z</div>' }
    it { is_expected.to be_html_safe }
  end
end
