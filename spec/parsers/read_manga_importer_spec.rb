describe ReadMangaImporter, vcr: { cassette_name: 'read_manga_parser' } do
  let(:importer) { ReadMangaImporter.new }

  describe 'import' do
    let!(:entry) { create :manga, name: "the magician's bride" }
    let(:identifier) { 'the_magician_s_bride' }

    subject(:manga) { entry.reload }

    describe 'pages' do
      before { allow_any_instance_of(ReadMangaParser).to receive(:fetch_page_links).and_return [identifier] }
      before { importer.import pages: [0] }

      it { expect(manga.description).to be_present }
    end

    describe 'pages' do
      before { allow_any_instance_of(ReadMangaParser).to receive(:fetch_page_links).and_return [identifier] }
      before { importer.import ids: [identifier] }

      it { expect(manga.description).to be_present }
    end
  end
end
