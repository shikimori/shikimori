describe BbCodes::Description do
  before do
    allow(BbCodes::Paragraphs).to receive(:call) { |text| text + 'p' }
    allow(BbCodes::CharactersNames).to receive(:call) { |text| text + 'c' }
  end

  subject! { described_class.call text, entry }
  let(:text) { 'z' }

  context 'entry with characters' do
    let(:entry) { build :anime }
    it { is_expected.to eq 'zcp' }
  end

  context 'entry without characters' do
    let(:entry) { build :character }
    it { is_expected.to eq 'zp' }
  end
end
