describe Import::Anime do
  let(:service) { Import::Anime.new data }
  let(:data) do
    {
      id: id,
      name: 'Test test 2',
      genres: genres
    }
  end
  let(:id) { 987_654_321 }
  let(:genres) { [] }

  subject(:entry) { service.call }

  it { expect(entry).to be_persisted }

  describe '#assign_genres' do
    let(:genres) { [{ id: 1, name: 'test' }] }

    context 'new genre' do
      it do
        expect(entry.reload.genres).to have(1).item
        expect(entry.genres.first).to have_attributes(
          mal_id: genres.first[:id],
          name: genres.first[:name]
        )
      end
    end

    context 'present genre' do
      let!(:genre) { create :genre, :anime, mal_id: genres.first[:id] }
      it do
        expect(entry.genres).to have(1).item
        expect(entry.genres.first).to have_attributes(
          mal_id: genre.mal_id,
          name: genre.name
        )
      end
    end
  end
end
