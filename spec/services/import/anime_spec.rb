describe Import::Anime do
  let(:service) { Import::Anime.new data }
  let(:data) do
    {
      id: id,
      name: 'Test test 2',
      genres: genres,
      studios: studios,
      related: related,
      recommendations: recommendations
    }
  end
  let(:id) { 987_654_321 }
  let(:genres) { [] }
  let(:studios) { [] }
  let(:related) { {} }
  let(:recommendations) { [] }

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

  describe '#assign_related' do
    let(:related) { { other: [{ id: 16_099, type: :anime }] } }

    describe 'import' do
      it do
        expect(entry.related).to have(1).item
        expect(entry.related.first).to have_attributes(
          anime_id: 16_099,
          manga_id: nil,
          relation: 'Other'
        )
      end
    end

    describe 'method call' do
      before { allow(Import::Related).to receive :call }
      it do
        expect(Import::Related)
          .to have_received(:call)
          .with entry, related
      end
    end
  end

  describe '#assign_recommendations' do
    let(:recommendations) { [{ id: 16_099, type: :anime }] }

    describe 'import' do
      it do
        expect(entry.similar).to have(1).item
        expect(entry.similar.first).to have_attributes(
          src_id: entry.id,
          dst_id: 16_099
        )
      end
    end

    describe 'method call' do
      before { allow(Import::Recommendations).to receive :call }
      it do
        expect(Import::Recommendations)
          .to have_received(:call)
          .with entry, recommendations
      end
    end
  end
end
