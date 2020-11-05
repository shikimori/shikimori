describe BbCodes::EntryText do
  before do
    allow(BbCodes::CharactersNames).to receive(:call) { |text| text + 'c' }
  end

  subject! { described_class.call text, entry: entry, locale: locale }
  let(:text) { '[[z]]' }
  let(:locale) { nil }

  context 'with charaacters' do
    let(:entry) { build :anime }

    it { is_expected.to eq '<div class="b-text_with_paragraphs">[[z]]c</div>' }
    it { is_expected.to be_html_safe }
  end

  context 'wo characters' do
    let(:entry) { build :person }

    it { is_expected.to eq '<div class="b-text_with_paragraphs">[[z]]</div>' }
    it { is_expected.to be_html_safe }
  end

  context 'character' do
    let(:entry) { build :character }

    it { is_expected.to eq '<div class="b-text_with_paragraphs">z</div>' }
    it { is_expected.to be_html_safe }
  end
end
