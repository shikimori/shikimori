describe ReadMangaImporter, vcr: { cassette_name: 'read_manga_parser' } do
  let(:importer) { ReadMangaImporter.new }

  describe 'import' do
    let!(:manga) { create :manga, id: 61189, name: "the magician's bride", description: description }
    let(:description) { 'test' }
    let(:identifier) { 'the_magician_s_bride' }

    describe 'pages' do
      before { allow_any_instance_of(ReadMangaParser).to receive(:fetch_page_links).and_return [identifier] }
      before { importer.import pages: [0] }

      it { expect(manga.reload.description).to be_present }
    end

    describe 'ids' do
      let!(:user_change) { }
      before { importer.import ids: [identifier] }
      it { expect(manga.reload.description).to be_present }

      context 'user changed manga' do
        let!(:user_change) { create :user_change, item_id: manga.id, model: Manga.name, column: 'description', status: UserChangeStatus::Taken }
        it { expect(manga.reload.description).to eq description }
      end
    end
  end
end
