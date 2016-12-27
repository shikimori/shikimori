describe Import::Anime do
  let(:service) { Import::Anime.new data }
  let(:data) do
    {
      id: id,
      name: 'Test test 2',
      genres: genres,
      studios: studios
    }
  end
  let(:id) { 987_654_321 }
  let(:genres) { [] }
  let(:studios) { [] }

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

  describe '#assign_studios' do
    let(:studios) { [{ id: 1, name: 'test' }] }

    context 'new studio' do
      it do
        expect(entry.reload.studios).to have(1).item
        expect(entry.studios.first).to have_attributes(
          id: studios.first[:id],
          name: studios.first[:name]
        )
      end
    end

    context 'present studio' do
      let!(:studio) { create :studio, id: studios.first[:id] }
      it do
        expect(entry.studios).to have(1).item
        expect(entry.studios.first).to have_attributes(
          id: studio.id,
          name: studio.name
        )
      end
    end
  end
end
