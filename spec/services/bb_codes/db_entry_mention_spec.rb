describe BbCodes::DbEntryMention do
  let!(:entry_1) { create :anime }
  let!(:entry_2) {}

  subject { described_class.call text }

  describe 'english' do
    context 'anime' do
      let!(:entry_1) { create :anime, name: "Hayate no Gotoku! Can't Take My Eyes Off You" }
      let(:text) { '[Hayate no Gotoku! Can&#x27;t Take My Eyes Off You]' }

      it { is_expected.to eq "[anime=#{entry_1.id}]" }

      context 'score order' do
        let!(:entry_1) { create :anime, name: 'test', score: 5 }
        let!(:entry_2) { create :anime, name: 'test', score: 9 }
        let(:text) { "[#{entry_1.name}]" }

        it { is_expected.to eq "[anime=#{entry_2.id}]" }
      end
    end

    context 'manga' do
      let!(:entry_1) { create :manga }
      let(:text) { "[#{entry_1.name}]" }

      it { is_expected.to eq "[manga=#{entry_1.id}]" }
    end

    context 'character' do
      let!(:entry_1) { create :character }
      let(:text) { "[#{entry_1.name}]" }

      it { is_expected.to eq "[character=#{entry_1.id}]" }

      context 'reversed name' do
        let(:text) { "[#{entry_1.name.split(' ').reverse.join ' '}]" }
        it { is_expected.to eq "[character=#{entry_1.id}]" }
      end
    end

    context 'person' do
      let!(:entry_1) { create :person }
      let(:text) { "[#{entry_1.name}]" }

      it { is_expected.to eq "[person=#{entry_1.id}]" }
    end
  end

  describe 'russian' do
    context 'anime' do
      let!(:entry_1) { create :anime, russian: 'руру' }
      let(:text) { "[#{entry_1.russian}]" }

      it { is_expected.to eq "[anime=#{entry_1.id}]" }
    end

    context 'manga' do
      let!(:entry_1) { create :manga, russian: 'руру' }
      let(:text) { "[#{entry_1.russian}]" }

      it { is_expected.to eq "[manga=#{entry_1.id}]" }
    end

    context 'character' do
      let!(:entry_1) { create :character, russian: 'руру' }
      let(:text) { "[#{entry_1.russian}]" }

      it { is_expected.to eq "[character=#{entry_1.id}]" }
    end
  end

  context 'no match' do
    let(:text) { '[test]' }
    it { is_expected.to eq '[test]' }
  end
end
