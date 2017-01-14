describe Import::Anime do
  let(:service) { Import::Anime.new data }
  let(:data) do
    {
      id: id,
      name: 'Test test 2',
      genres: genres,
      studios: studios,
      related: related,
      recommendations: similarities,
      characters: characters_data,
      synopsis: synopsis,
      external_links: external_links,
      image: image
    }
  end
  let(:id) { 987_654_321 }
  let(:genres) { [] }
  let(:studios) { [] }
  let(:related) { {} }
  let(:similarities) { [] }
  let(:characters_data) { { characters: characters, staff: staff } }
  let(:characters) { [] }
  let(:staff) { [] }
  let(:synopsis) { '' }
  let(:external_links) { [] }
  let(:image) { nil }

  subject(:entry) { service.call }

  it do
    expect(entry).to be_persisted
    expect(entry).to be_kind_of Anime
    expect(entry).to have_attributes data.except(
      :synopsis, :image, :genres, :studios, :related, :recommendations,
      :characters, :external_links
    )
  end

  describe '#assign_synopsis' do
    let(:synopsis) { '<b>test</b>' }
    let(:synopsis_with_source) do
      "[b]test[/b][source]http://myanimelist.net/anime/#{id}[/source]"
    end

    it { expect(entry.description_en).to eq synopsis_with_source }

    describe 'anidb external_link' do
      let!(:anime) { create :anime, id: 987_654_321, description_en: 'old' }
      let!(:external_link) do
        create :external_link,
          entry: anime,
          source: :anime_db,
          imported_at: imported_at
      end

      describe 'imported' do
        let(:imported_at) { Time.zone.now }
        it { expect(entry.description_en).to eq 'old' }
      end

      describe 'not imported' do
        let(:imported_at) { nil }
        it { expect(entry.description_en).to eq synopsis_with_source }
      end
    end
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

    describe 'does not clear' do
      let!(:related_anime) do
        create :related_anime,
          source_id: id,
          relation: 'Adaptation',
          manga_id: 21_479
      end
      let(:related) { {} }
      before { subject }

      it { expect(related_anime.reload).to be_persisted }
    end
  end

  describe '#assign_recommendations' do
    let(:similarities) { [{ id: 16_099, type: :anime }] }

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
      let!(:similar_anime) do
        create :similar_anime,
          src_id: id,
          dst_id: 28_735
      end
      let(:similarities) { [] }
      before { subject }

      it { expect(similar_anime.reload).to be_persisted }
    end
  end

  describe '#assign_external_links' do
    let(:external_links) do
      [{
        source: 'official_site',
        url: 'http://www.cowboy-bebop.net/'
      }]
    end

    describe 'import' do
      it do
        expect(entry.reload.external_links).to have(1).item
        expect(entry.external_links.first).to have_attributes(
          entry_id: entry.id,
          entry_type: entry.class.name,
          source: 'official_site',
          url: 'http://www.cowboy-bebop.net/'
        )
      end
    end

    describe 'method call' do
      before { allow(Import::ExternalLinks).to receive :call }
      it do
        expect(Import::ExternalLinks)
          .to have_received(:call)
          .with entry, external_links
      end
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
          anime_id: entry.id,
          manga_id: nil,
          character_id: 143_628,
          person_id: nil,
          role: 'Main'
        )
        expect(person_roles.last).to have_attributes(
          anime_id: entry.id,
          manga_id: nil,
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
          anime_id: id,
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
