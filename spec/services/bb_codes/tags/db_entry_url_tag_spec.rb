describe BbCodes::Tags::DbEntryUrlTag do
  subject { described_class.instance.format text }

  context 'random shikimori url' do
    let(:text) { '//shikimori.test/animes' }
    it { is_expected.to eq text }
  end

  context 'random not shikimori url' do
    let(:text) { '//zzz.com/animes' }
    it { is_expected.to eq text }
  end

  context 'db_entry url' do
    context 'anime' do
      let(:text) { '//shikimori.test/animes/1-qwe' }
      it { is_expected.to eq "[anime=1 fallback=#{text}]" }
    end

    context 'manga' do
      let(:text) { '//shikimori.test/mangas/1-qwe' }
      it { is_expected.to eq "[manga=1 fallback=#{text}]" }
    end

    context 'ranobe' do
      let(:text) { '//shikimori.test/ranobe/1-qwe' }
      it { is_expected.to eq "[ranobe=1 fallback=#{text}]" }
    end

    context 'character' do
      let(:text) { '//shikimori.test/characters/1-qwe' }
      it { is_expected.to eq "[character=1 fallback=#{text}]" }
    end

    context 'person' do
      let(:text) { '//shikimori.test/people/1-qwe' }
      it { is_expected.to eq "[person=1 fallback=#{text}]" }
    end

    context 'copyrighted' do
      let(:text) { '//shikimori.test/animes/qwert1-qwe' }
      it { is_expected.to eq "[anime=1 fallback=#{text}]" }
    end
  end

  context 'db_entry nested url' do
    let(:text) { '//shikimori.test/animes/1-test/qwe' }
    it { is_expected.to eq text }
  end

  context 'not raw url' do
    let(:text) { '[test=http://shikimori.test/animes/1]' }
    it { is_expected.to eq text }
  end
end
