describe ReadMangaImporter, vcr: { cassette_name: 'read_manga_parser' } do
  let(:importer) { ReadMangaImporter.new }

  describe 'import' do
    let!(:manga) { create :manga, id: 61189, name: "the magician's bride",
      description_ru: description_ru }
    let(:description_ru) { 'test' }
    let(:identifier) { 'the_magician_s_bride' }

    describe 'pages' do
      before { allow_any_instance_of(ReadMangaParser)
        .to receive(:fetch_page_links).and_return [identifier] }
      before { importer.import pages: [0] }

      it { expect(manga.reload.description_ru).to be_present }
    end

    describe 'ids' do
      context 'not changed manga' do
        before { importer.import ids: [identifier] }

        it do
          expect(manga.reload.description_ru).to be_present
          expect(manga.description_ru).to_not eq description_ru
        end
      end

      context 'changed manga' do
        let!(:version) { create :version, item: manga,
          item_diff: { 'description_ru': ['1','2'] }, state: :taken }
        before { importer.import ids: [identifier] }

        it { expect(manga.reload.description_ru).to eq description_ru }
      end
    end
  end
end
