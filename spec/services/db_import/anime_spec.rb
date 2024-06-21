describe DbImport::Anime do
  let(:service) { described_class.new data }
  let(:data) do
    {
      id:,
      name: 'Test test 2',
      season: 'fall_2012',
      rating:,
      genres:,
      studios:,
      related:,
      recommendations: similarities,
      characters: characters_data,
      synopsis:,
      external_links:,
      image:,
      is_more_info:
    }
  end
  let(:id) { 987_654_321 }
  let(:rating) { 'pg' }
  let(:genres) { [] }
  let(:studios) { [] }
  let(:related) { {} }
  let(:similarities) { [] }
  let(:characters_data) { { characters:, staff: } }
  let(:characters) { [] }
  let(:staff) { [] }
  let(:synopsis) { '' }
  let(:external_links) { [] }
  let(:image) { nil }
  let(:is_more_info) { false }

  before do
    allow(MalParser::Entry::MoreInfo)
      .to receive(:call)
      .with(id, :anime)
      .and_return imported_more_info
  end
  let(:imported_more_info) { 'qwe' }

  subject(:entry) { service.call }

  it do
    expect(entry).to be_persisted
    expect(entry).to be_kind_of Anime
    expect(entry).to have_attributes data.except(
      :synopsis, :image, :genres, :studios, :related, :recommendations,
      :characters, :external_links, :is_more_info
    )
    expect(MalParser::Entry::MoreInfo).to_not have_received :call
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
          imported_at:
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
    # before { AnimeGenresV2Repository.instance.reset }
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
          entry_type: 'Anime'
        )
      end
    end

    context 'present genre' do
      let!(:genre) do
        create :genre_v2, :anime, :theme,
          name: genres.first[:name],
          mal_id: genres.first[:id]
      end
      let!(:anime) do
        create :anime, id: 987_654_321, description_en: 'old', genre_v2_ids: [genre.id]
      end

      it do
        expect { subject }.to_not change GenreV2, :count
        expect(entry.reload.genres_v2).to have(1).item
      end
    end

    context 'girls/boys love' do
      let(:genres) do
        [
          lgbt_genre_mal,
          censored_genre_mal
        ].compact
      end
      let(:lgbt_genre_mal) do
        { id: 1_987_654, name: described_class::LGBT_GENRES.values.sample, kind: 'genre' }
      end

      context 'no hentai/erotica' do
        let(:censored_genre_mal) { nil }
        it do
          expect { subject }.to change(GenreV2, :count).by 1
          expect(entry.reload.genres_v2).to have(1).item
          expect(entry.genres_v2[0]).to have_attributes(
            mal_id: genres[0][:id],
            name: genres[0][:name],
            russian: genres[0][:name],
            kind: genres[0][:kind],
            entry_type: 'Anime'
          )
        end
      end

      context 'hentai/erotica' do
        let(:censored_genre_mal) do
          { id: 1_987_654, name: described_class::CENSORED_GENRES.sample, kind: 'genre' }
        end

        let!(:yaoi_manga) { create :genre_v2, name: 'Yaoi', entry_type: 'Manga' }
        let!(:yaoi) { create :genre_v2, name: 'Yaoi', entry_type: 'Anime' }
        let!(:yuri) { create :genre_v2, name: 'Yuri', entry_type: 'Anime' }

        it do
          expect { subject }.to_not change GenreV2, :count
          expect(entry.reload.genres_v2).to have(1).item
          expect(entry.genres_v2[0]).to have_attributes(
            mal_id: nil,
            name: lgbt_genre_mal[:name] == 'Boys Love' ? yaoi.name : yuri.name,
            entry_type: 'Anime'
          )
        end
      end
    end
  end

  describe '#assign_studios' do
    let(:studios) { [{ id: 1, name: 'test' }] }

    context 'new studio' do
      it do
        expect(entry.reload.studios).to have(1).item
        expect(entry.studios[0]).to have_attributes(
          id: studios[0][:id],
          name: studios[0][:name]
        )
      end
    end

    context 'present studio' do
      let!(:studio) do
        create :studio,
          id: studios.first[:id],
          name: studio_name,
          desynced:
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
      let!(:related_anime) do
        create :related_anime,
          source_id: id,
          manga_id: 21_479,
          relation_kind: Types::RelatedAniManga::RelationKind[:adaptation]
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

  # describe 'censored' do
  #   let(:genres) { [{ id: genre_id, name: 'test' }] }
  #   let!(:genre) { create :genre, id: 98765, mal_id: genre_id, name: 'test' }
  #
  #   describe 'by rating' do
  #     let(:genre_id) { 1 }
  #
  #     context 'not rx' do
  #       let(:rating) { 'pg' }
  #       it do
  #         expect(entry.rating).to eq 'pg'
  #         expect(entry.is_censored).to eq false
  #       end
  #     end
  #
  #     context 'rx' do
  #       let(:rating) { 'rx' }
  #       it do
  #         expect(entry.rating).to eq 'rx'
  #         expect(entry.is_censored).to eq true
  #       end
  #     end
  #   end
  #
  #   context 'by genre' do
  #     context 'not hentai' do
  #       let(:genre_id) { 1 }
  #       it { expect(entry.is_censored).to eq false }
  #     end
  #
  #     context 'hentai' do
  #       let(:genre_id) { Genre::CENSORED_IDS.sample }
  #       before { allow_any_instance_of(Genre).to receive(:id).and_return genre_id }
  #       it { expect(entry.is_censored).to eq true }
  #     end
  #   end
  # end

  context 'is_more_info' do
    let(:is_more_info) { true }

    it do
      expect(entry).to be_persisted
      expect(entry.more_info).to eq imported_more_info
      expect(MalParser::Entry::MoreInfo).to have_received :call
    end

    context 'more_info is already set' do
      let!(:anime) { create :anime, id:, more_info: 'zxc' }

      it do
        expect(entry).to eq anime
        expect(entry.more_info).to_not eq imported_more_info
        expect(MalParser::Entry::MoreInfo).to_not have_received :call
      end
    end
  end
end
