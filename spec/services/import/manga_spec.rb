describe Import::Manga do
  let(:service) { Import::Manga.new data }
  let(:data) do
    {
      id: id,
      name: 'Test test 2',
      genres: genres,
      publishers: publishers,
      related: related,
      recommendations: similarities,
      characters: characters_data,
      synopsis: synopsis,
      image: image
    }
  end
  let(:id) { 987_654_321 }
  let(:genres) { [] }
  let(:publishers) { [] }
  let(:related) { {} }
  let(:similarities) { [] }
  let(:characters_data) { { characters: characters, staff: staff } }
  let(:characters) { [] }
  let(:staff) { [] }
  let(:synopsis) { '' }
  let(:image) { nil }

  subject(:entry) { service.call }

  it { expect(entry).to be_persisted }

  describe '#assign_synopsis' do
    let(:synopsis) { '<b>test</b>' }
    let(:synopsis_with_source) do
      "[b]test[/b][source]http://myanimelist.net/manga/#{id}[/source]"
    end

    it { expect(entry.description_en).to eq synopsis_with_source }
  end

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
      let!(:genre) { create :genre, :manga, mal_id: genres.first[:id] }
      it do
        expect(entry.genres).to have(1).item
        expect(entry.genres.first).to have_attributes(
          mal_id: genre.mal_id,
          name: genre.name
        )
      end
    end
  end

  describe '#assign_publishers' do
    let(:publishers) { [{ id: 1, name: 'test' }] }

    context 'new publisher' do
      it do
        expect(entry.reload.publishers).to have(1).item
        expect(entry.publishers.first).to have_attributes(
          id: publishers.first[:id],
          name: publishers.first[:name]
        )
      end
    end

    context 'present publisher' do
      let!(:publisher) { create :publisher, id: publishers.first[:id] }
      it do
        expect(entry.publishers).to have(1).item
        expect(entry.publishers.first).to have_attributes(
          id: publisher.id,
          name: publisher.name
        )
      end
    end
  end

  describe '#assign_related' do
    let(:related) { { other: [{ id: 16_099, type: :manga }] } }

    describe 'import' do
      it do
        expect(entry.related).to have(1).item
        expect(entry.related.first).to have_attributes(
          anime_id: nil,
          manga_id: 16_099,
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

    describe 'does not clear' do
      let!(:related_manga) do
        create :related_manga,
          source_id: id,
          relation: 'Adaptation',
          anime_id: 21_479
      end
      let(:related) { {} }
      before { subject }

      it { expect(related_manga.reload).to be_persisted }
    end
  end

  describe '#assign_recommendations' do
    let(:similarities) { [{ id: 16_099, type: :manga }] }

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
      before { allow(Import::Similarities).to receive :call }
      it do
        expect(Import::Similarities)
          .to have_received(:call)
          .with entry, similarities
      end
    end

    describe 'does not clear' do
      let!(:similar_manga) do
        create :similar_manga,
          src_id: id,
          dst_id: 28_735
      end
      let(:similarities) { [] }
      before { subject }

      it { expect(similar_manga.reload).to be_persisted }
    end
  end

  describe '#assign_characters' do
    let(:characters) { [{ id: 143_628, role: 'Main' }] }
    let(:staff) { [{ id: 33_365, role: 'Director' }] }

    describe 'import' do
      let(:person_roles) { entry.person_roles.order :id }
      it do
        expect(person_roles).to have(2).items
        expect(person_roles.first).to have_attributes(
          anime_id: nil,
          manga_id: entry.id,
          character_id: 143_628,
          person_id: nil,
          role: 'Main'
        )
        expect(person_roles.last).to have_attributes(
          anime_id: nil,
          manga_id: entry.id,
          character_id: nil,
          person_id: 33_365,
          role: 'Director'
        )
      end
    end

    describe 'method call' do
      before { allow(Import::PersonRoles).to receive :call }
      it do
        expect(Import::PersonRoles)
          .to have_received(:call)
          .with entry, characters, staff
      end
    end

    describe 'does not clear' do
      let!(:person_role) do
        create :person_role,
          manga_id: id,
          character_id: 28_735,
          role: 'Main'
      end
      let(:characters) { [] }
      let(:staff) { [] }
      before { subject }

      it { expect(person_role.reload).to be_persisted }
    end
  end

  describe '#assign_image' do
    let(:image) { 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/PNG_transparency_demonstration_1.png/240px-PNG_transparency_demonstration_1.png' }

    describe 'import', :vcr do
      it { expect(entry.image).to be_present }
    end

    describe 'method call' do
      before { allow(Import::MalImage).to receive :call }
      it do
        expect(Import::MalImage)
          .to have_received(:call)
          .with entry, image
      end
    end
  end
end

