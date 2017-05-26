describe ReadMangaImporter, vcr: { cassette_name: 'read_manga_parser' } do
  let(:importer) { ReadMangaImporter.new }

  describe 'import' do
    let!(:manga) do
      create :manga,
        id: 61189,
        name: "the magician's bride",
        description_ru: description_ru
    end
    let!(:external_link) {}
    let(:description_ru) { 'test' }
    let(:identifier) { 'the_magician_s_bride' }

    describe 'pages' do
      before { allow_any_instance_of(ReadMangaParser)
        .to receive(:fetch_page_links).and_return [identifier] }
      before { importer.import pages: [0] }

      it { expect(manga.reload.description_ru).to be_present }
    end

    describe 'ids' do
      describe 'readmanga_external_link' do
        before { importer.import ids: [identifier] }

        context 'no external link' do
          it do
            expect(manga.readmanga_external_link).to be_persisted
            expect(manga.readmanga_external_link).to have_attributes(
              url: 'http://readmanga.ru/the_magician_s_bride',
              kind: 'readmanga',
              source: 'myanimelist'
            )
          end
        end

        context 'with external link' do
          let!(:external_link) do
            create :external_link,
              entry: manga,
              kind: Types::ExternalLink::Kind[:readmanga],
              url: 'zzz.com'
          end

          it do
            expect(manga.readmanga_external_link).to have_attributes(
              id: external_link.id,
              url: 'http://readmanga.ru/the_magician_s_bride',
              kind: 'readmanga',
              source: 'myanimelist'
            )
          end
        end
      end

      describe 'description_ru' do
        context 'not changed manga' do
          before { importer.import ids: [identifier] }

          it do
            expect(manga.reload.description_ru).to be_present
            expect(manga.description_ru).to_not eq description_ru
          end
        end

        context 'changed manga' do
          let!(:version) do
            create :version,
              item: manga,
              item_diff: { 'description_ru': %w[1 2] },
              state: :taken
          end
          before { importer.import ids: [identifier] }

          it { expect(manga.reload.description_ru).to eq description_ru }
        end
      end
    end
  end
end
