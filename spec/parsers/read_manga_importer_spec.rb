describe ReadMangaImporter, vcr: { cassette_name: 'read_manga_parser' } do
  let(:importer) { ReadMangaImporter.new }

  describe 'import' do
    let!(:manga) do
      create :manga,
        id: 61_189,
        name: "the magician's bride",
        description_ru: description_ru
    end
    let!(:manga_2) do
      create :manga,
        id: 61_190,
        name: 'zzz',
        description_ru: description_ru
    end
    let(:description_ru) { 'test' }
    let(:identifier) { 'the_magician_s_bride' }

    describe 'pages' do
      before do
        allow_any_instance_of(ReadMangaParser)
          .to receive(:fetch_page_links).and_return [identifier]
      end
      subject! { importer.import pages: [0] }

      it { expect(manga.reload.description_ru).to be_present }
    end

    describe 'ids' do
      let!(:external_link) {}
      let!(:version) {}

      subject! { importer.import ids: [identifier] }

      describe 'readmanga_external_link' do
        context 'no external link' do
          it do
            expect(manga.reload.description_ru).to_not eq description_ru
            expect(manga_2.reload.description_ru).to eq description_ru

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
              entry: external_link_entry,
              kind: Types::ExternalLink::Kind[:readmanga],
              url: url
          end
          let(:external_link_entry) { manga }

          context 'urls are matched' do
            let(:url) { 'http://readmanga.ru/the_magician_s_bride' }
            it do
              expect(manga.reload.description_ru).to_not eq description_ru
              expect(manga_2.reload.description_ru).to eq description_ru

              expect(manga.readmanga_external_link).to have_attributes(
                external_link.attributes.except('created_at', 'updated_at')
              )
            end
          end

          context 'urls are not matched' do
            let(:url) { 'http://readmanga.ru/the_magician_s_bridezz' }

            it do
              expect(manga.reload.description_ru).to eq description_ru
              expect(manga_2.reload.description_ru).to eq description_ru
            end
          end

          context 'another manga matched' do
            let(:url) { 'http://readmanga.ru/the_magician_s_bride' }
            let(:external_link_entry) { manga_2 }
            it do
              expect(manga.reload.description_ru).to eq description_ru
              expect(manga_2.reload.description_ru).to_not eq description_ru
            end
          end
        end
      end

      describe 'description_ru' do
        context 'not changed manga' do
          it do
            expect(manga.reload.description_ru).to_not eq description_ru
            expect(manga_2.reload.description_ru).to eq description_ru
            expect(manga.reload.description_ru).to be_present
          end
        end

        context 'changed manga' do
          let!(:version) do
            create :version,
              item: manga,
              item_diff: { 'description_ru': %w[1 2] },
              state: :taken
          end
          it do
            expect(manga.reload.description_ru).to eq description_ru
            expect(manga_2.reload.description_ru).to eq description_ru
          end
        end
      end
    end
  end
end
