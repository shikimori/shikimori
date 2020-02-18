describe NameMatches::Refresh do
  let(:worker) { NameMatches::Refresh.new }

  describe '#perform' do
    let!(:anime) { create :anime, name: 'test', russian: '', id: 999_999 }
    let!(:anime_2) { create :anime, name: 'test2', russian: '', id: 999_998 }

    let!(:anime_match) { create :name_match, target: anime }
    let!(:anime_match_2) do
      create :name_match, target: build_stubbed(:anime, id: 999_997)
    end
    let!(:manga_match) do
      create :name_match, target: build_stubbed(:manga, id: 999_996)
    end

    context 'without ids' do
      before { worker.perform Anime.name }
      it do
        expect(anime.name_matches).to have(2).items
        expect(anime_2.name_matches).to have(2).items
        expect { anime_match.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(anime_match_2.reload).to be_persisted
        expect(manga_match.reload).to be_persisted
      end
    end

    context 'with ids' do
      before { worker.perform Anime.name, [anime.id] }
      it do
        expect(anime.name_matches).to have(2).items
        expect(anime_2.name_matches).to be_empty
        expect { anime_match.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(anime_match_2.reload).to be_persisted
        expect(manga_match.reload).to be_persisted
      end
    end
  end
end
