describe DbEntries::RecalculateRanked do
  let(:worker) { described_class.new }

  describe '#perform' do
    let!(:anime_1) { create :anime, score_2: 5 }
    let!(:anime_2) { create :anime, score_2: 10 }

    context 'random' do
      before { worker.perform Anime.name, :random }

      it do
        expect(anime_1.reload.ranked_random).not_to be_nil
        expect(anime_2.reload.ranked_random).not_to be_nil
      end
    end

    context 'shiki' do
      before { worker.perform Anime.name, :shiki }

      it do
        expect(anime_1.reload.ranked_shiki).to eq 2
        expect(anime_2.reload.ranked_shiki).to eq 1
      end
    end
  end
end
