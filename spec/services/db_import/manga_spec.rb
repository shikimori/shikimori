describe DbImport::Manga do
  let(:service) { described_class.new data }
  let(:data) do
    {
      id:,
      name: 'Test test 2',
      genres:,
      publishers:,
      related:,
      recommendations: similarities,
      characters: characters_data,
      synopsis:,
      image:,
      is_more_info: true
    }
  end
  let(:id) { 987_654_321 }
  let(:genres) { [] }
  let(:publishers) { [] }
  let(:related) { {} }
  let(:similarities) { [] }
  let(:characters_data) { { characters:, staff: } }
  let(:characters) { [] }
  let(:staff) { [] }
  let(:synopsis) { '' }
  let(:image) { nil }

  before do
    allow(MalParser::Entry::MoreInfo)
      .to receive(:call)
      .with(id, :manga)
      .and_return imported_more_info
  end
  let(:imported_more_info) { 'qwe' }

  subject(:entry) { service.call }

  it do
    expect(entry).to be_persisted
    expect(entry).to_not be_changed
    expect(entry).to be_kind_of Manga
    expect(entry).to have_attributes data.except(
      :synopsis, :image, :genres, :publishers, :related, :recommendations,
      :characters, :is_more_info
    )
    expect(entry.more_info).to eq imported_more_info
  end

  describe '#assign_synopsis' do
    let(:synopsis) { '<b>test</b>' }
    let(:synopsis_with_source) do
      "[b]test[/b][source]http://myanimelist.net/manga/#{id}[/source]"
    end

    it { expect(entry.description_en).to eq synopsis_with_source }
  end

  describe '#assign_genres' do
    before { MangaGenresV2Repository.instance.reset }
    let(:genres) { [{ id: 987_654, name: 'test', kind: 'theme' }] }

    context 'new genre' do
      it do
        expect { subject }.to change(GenreV2, :count).by 1
        expect(entry.reload.genres_v2).to have(1).item
        expect(entry.genres_v2[0]).to have_attributes(
          mal_id: genres[0][:id],
          name: genres[0][:name],
          russian: genres[0][:name],
          kind: genres[0][:kind],
          entry_type: 'Manga'
        )
      end
    end

    context 'present genre' do
      let!(:genre) do
        create :genre_v2, :manga, :theme,
          name: genres.first[:name],
          mal_id: genres.first[:id]
      end
      let!(:manga) { create :manga, id: 987_654_321, description_en: 'old', genre_v2_ids: [genre.id] }

      it do
        expect { subject }.to_not change GenreV2, :count
        expect(entry.reload.genres_v2).to have(1).item
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
      let!(:publisher) do
        create :publisher,
          id: publishers.first[:id],
          name: publisher_name,
          desynced:
      end
      let(:publisher_name) { publishers.first[:name] }
      let(:desynced) { [] }

      describe 'imported' do
        let!(:manga) { create :manga, id: 987_654_321, description_en: 'old' }
        before { manga.publishers << publisher }

        it do
          expect(entry.publishers).to have(1).item
          expect(entry.publishers.first).to have_attributes(
            id: publisher.id,
            name: publisher.name
          )
        end

        describe 'updates name' do
          let(:publisher_name) { 'zxc' }

          it do
            expect(entry.publishers).to have(1).item
            expect(entry.publishers.first).to have_attributes(
              id: publisher.id,
              name: publishers.first[:name]
            )
          end

          context 'desynced name ignored' do
            let(:desynced) { %w[name] }
            it do
              expect(entry.publishers).to have(1).item
              expect(entry.publishers.first).to have_attributes(
                id: publisher.id,
                name: publisher.name
              )
            end
          end
        end
      end

      context 'not imported' do
        it do
          expect(entry.publishers).to have(1).item
          expect(entry.publishers.first).to have_attributes(
            id: publisher.id,
            name: publisher.name
          )
        end
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
          relation_kind: Types::RelatedAniManga::RelationKind[:other].to_s
        )
      end
    end

    describe 'method call' do
      before { allow(DbImport::Related).to receive :call }
      it do
        expect(DbImport::Related)
          .to have_received(:call)
          .with entry, related
      end
    end

    describe 'does not clear' do
      let!(:related_manga) do
        create :related_manga,
          source_id: id,
          anime_id: 21_479,
          relation_kind: Types::RelatedAniManga::RelationKind[:adaptation]
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
      before { allow(DbImport::Similarities).to receive :call }
      it do
        expect(DbImport::Similarities)
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
    let(:characters) { [{ id: 143_628, roles: %w[Main] }] }
    let(:staff) { [{ id: 33_365, roles: %w[Director] }] }

    describe 'import' do
      let(:person_roles) { entry.person_roles.order :id }
      it do
        expect(person_roles).to have(2).items
        expect(person_roles.first).to have_attributes(
          anime_id: nil,
          manga_id: entry.id,
          character_id: 143_628,
          person_id: nil,
          roles: %w[Main]
        )
        expect(person_roles.last).to have_attributes(
          anime_id: nil,
          manga_id: entry.id,
          character_id: nil,
          person_id: 33_365,
          roles: %w[Director]
        )
      end
    end

    describe 'method call' do
      before { allow(DbImport::PersonRoles).to receive :call }
      it do
        expect(DbImport::PersonRoles)
          .to have_received(:call)
          .with entry, characters, staff
      end
    end

    describe 'does not clear' do
      let!(:person_role) do
        create :person_role,
          manga_id: id,
          character_id: 28_735,
          roles: %w[Main]
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
      it { expect(entry.image).to_not be_present }
      # it { expect(entry.image).to be_present }
    end

    describe 'method call' do
      before do
        allow(DbImport::MalImage).to receive :call
        allow(DbImport::MalPoster).to receive :call
      end
      it do
        expect(DbImport::MalImage).to_not have_received :call
          # .to have_received(:call)
          # .with entry:, image_url: image
        expect(DbImport::MalPoster)
          .to have_received(:call)
          .with entry:, image_url: image
      end
    end
  end
end
