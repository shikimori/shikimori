describe DbImport::Anime do
  let(:service) { described_class.new data }
  let(:data) do
    {
      id: id,
      name: 'Test test 2',
      season: 'fall_2012',
      rating: rating,
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
  let(:rating) { 'pg' }
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
          kind: :anime_db,
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

  # describe '#assign_genres' do
  #   let(:genres) { [{ id: 1, name: 'test' }] }
  #
  #   context 'new genre' do
  #     it do
  #       expect { subject }.to raise_error(
  #         ArgumentError,
  #         'unknown genre: {"id":1,"name":"test"}'
  #       )
  #     end
  #   end
  #
  #   context 'present genre' do
  #     let!(:genre) { create :genre, :anime, name: genres.first[:name], mal_id: genres.first[:id] }
  #
  #     describe 'imported' do
  #       let!(:anime) { create :anime, id: 987_654_321, description_en: 'old' }
  #       before { anime.genres << genre }
  #
  #       it do
  #         expect(entry.genres).to have(1).item
  #         expect(entry.genres.first).to have_attributes(
  #           id: genre.id,
  #           mal_id: genre.mal_id,
  #           name: genre.name
  #         )
  #       end
  #     end
  #
  #     context 'not imported' do
  #       it do
  #         expect(entry.genres).to have(1).item
  #         expect(entry.genres.first).to have_attributes(
  #           id: genre.id,
  #           mal_id: genre.mal_id,
  #           name: genre.name
  #         )
  #       end
  #     end
  #   end
  # end

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
      let!(:studio) do
        create :studio,
          id: studios.first[:id],
          name: studio_name,
          desynced: desynced
      end
      let(:studio_name) { studios.first[:name] }
      let(:desynced) { [] }

      describe 'imported' do
        let!(:anime) { create :anime, id: 987_654_321, description_en: 'old' }
        before { anime.studios << studio }

        it do
          expect(entry.studios).to have(1).item
          expect(entry.studios.first).to have_attributes(
            id: studio.id,
            name: studio.name
          )
        end

        describe 'updates name' do
          let(:studio_name) { 'zxc' }

          it do
            expect(entry.studios).to have(1).item
            expect(entry.studios.first).to have_attributes(
              id: studio.id,
              name: studios.first[:name]
            )
          end

          context 'desynced name ignored' do
            let(:desynced) { %w[name] }
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

      context 'not imported' do
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
      before { allow(DbImport::Related).to receive :call }
      it do
        expect(DbImport::Related)
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
      before { allow(DbImport::Similarities).to receive :call }
      it do
        expect(DbImport::Similarities)
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
        kind: 'official_site',
        url: 'http://www.cowboy-bebop.net/'
      }]
    end

    describe 'import' do
      it do
        expect(entry.reload.all_external_links).to have(1).item
        expect(entry.all_external_links.first).to have_attributes(
          entry_id: entry.id,
          entry_type: entry.class.name,
          source: 'myanimelist',
          kind: 'official_site',
          url: 'http://www.cowboy-bebop.net/'
        )
      end
    end

    describe 'method call' do
      before { allow(DbImport::ExternalLinks).to receive :call }
      it do
        expect(DbImport::ExternalLinks)
          .to have_received(:call)
          .with entry, external_links
      end
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
          anime_id: entry.id,
          manga_id: nil,
          character_id: 143_628,
          person_id: nil,
          roles: %w[Main]
        )
        expect(person_roles.last).to have_attributes(
          anime_id: entry.id,
          manga_id: nil,
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
          anime_id: id,
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
      it { expect(entry.image).to be_present }
    end

    describe 'method call' do
      before { allow(DbImport::MalImage).to receive :call }
      it do
        expect(DbImport::MalImage)
          .to have_received(:call)
          .with entry, image
      end
    end
  end

  describe 'censored' do
    let(:genres) { [{ id: genre_id, name: 'test' }] }
    let!(:genre) { create :genre, id: 98765, mal_id: genre_id, name: 'test' }

    describe 'by rating' do
      let(:genre_id) { 1 }

      context 'not rx' do
        let(:rating) { 'pg' }
        it do
          expect(entry.rating).to eq 'pg'
          expect(entry.is_censored).to eq false
        end
      end

      context 'rx' do
        let(:rating) { 'rx' }
        it do
          expect(entry.rating).to eq 'rx'
          expect(entry.is_censored).to eq true
        end
      end
    end

    # context 'by genre' do
    #   context 'not hentai' do
    #     let(:genre_id) { 1 }
    #     it { expect(entry.is_censored).to eq false }
    #   end
    #
    #   context 'hentai' do
    #     let(:genre_id) { Genre::CENSORED_IDS.sample }
    #     before { allow_any_instance_of(Genre).to receive(:id).and_return genre_id }
    #     it { expect(entry.is_censored).to eq true }
    #   end
    # end
  end
end
