describe RefreshNameMatches do
  let(:worker) { RefreshNameMatches.new }

  describe '#perform' do
    subject(:perform) { worker.perform Anime.name }

    describe 'cleans old matches' do
      let!(:anime_match) { create :name_match, target: build_stubbed(:anime) }
      let!(:manga_match) { create :name_match, target: build_stubbed(:manga) }

      before { subject }

      it do
        expect{anime_match.reload}.to raise_error ActiveRecord::RecordNotFound
        expect(manga_match.reload).to be_persisted
      end
    end
  end
end
