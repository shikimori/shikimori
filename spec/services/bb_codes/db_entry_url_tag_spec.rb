describe BbCodes::DbEntryUrlTag do
  subject { BbCodes::DbEntryUrlTag.instance.format text }

  describe '#format' do
    context 'random shikimori url' do
      let(:text) { '//shikimori.org/animes' }
      it { is_expected.to eq text }
    end

    context 'random not shikimori url' do
      let(:text) { '//zzz.com/animes' }
      it { is_expected.to eq text }
    end

    context 'db_entry url' do
      context 'anime' do
        let(:text) { '//shikimori.org/animes/1-qwe' }
        it { is_expected.to eq "[anime=1 fallback=#{text}]" }
      end

      context 'manga' do
        let(:text) { '//shikimori.org/mangas/1-qwe' }
        it { is_expected.to eq "[manga=1 fallback=#{text}]" }
      end

      context 'character' do
        let(:text) { '//shikimori.org/characters/1-qwe' }
        it { is_expected.to eq "[character=1 fallback=#{text}]" }
      end

      context 'person' do
        let(:text) { '//shikimori.org/people/1-qwe' }
        it { is_expected.to eq "[person=1 fallback=#{text}]" }
      end

      context 'copyrighted' do
        let(:text) { '//shikimori.org/animes/qwert1-qwe' }
        it { is_expected.to eq "[anime=1 fallback=#{text}]" }
      end
    end

    context 'db_entry nested url' do
      let(:text) { '//shikimori.org/animes/1-test/qwe' }
      it { is_expected.to eq text }
    end

    context 'not raw url' do
      let(:text) { '[test=http://shikimori.org/animes/1]' }
      it { is_expected.to eq text }
    end
  end
end
