describe MalParsers::FetchPage do
  let(:worker) { MalParsers::FetchPage.new }

  describe '#perform' do
    let(:type) { 'anime' }
    let(:page) { 0 }
    let(:sorting) { :name }
    let(:max_pages) { 9999 }

    before do
      allow(MalParser::Catalog::Page).to receive(:call).and_return entries
      allow(MalParsers::FetchPage).to receive :perform_async
      allow(MalParsers::FetchEntry).to receive :perform_async
    end
    subject! { worker.perform type, page, sorting, max_pages }

    let(:entries_count) { MalParser::Catalog::Page::ENTRIES_PER_PAGE }
    let(:entries) { Array.new(entries_count).map { { id: 1, type: :anime } } }

    it do
      expect(MalParsers::FetchPage)
        .to have_received(:perform_async)
        .with(type, page + 1, sorting, max_pages)
      expect(MalParsers::FetchEntry)
        .to have_received(:perform_async)
        .with(entries.first[:id], entries.first[:type])
        .exactly(entries_count).times
    end

    context 'low entries count' do
      let(:entries_count) { MalParser::Catalog::Page::ENTRIES_PER_PAGE - 1 }

      it do
        expect(MalParsers::FetchPage).to_not have_received :perform_async
        expect(MalParsers::FetchEntry)
          .to have_received(:perform_async)
          .with(entries.first[:id], entries.first[:type])
          .exactly(entries_count).times
      end
    end

    context 'last planned page' do
      let(:page) { max_pages }
      it do
        expect(MalParsers::FetchPage).to_not have_received :perform_async
        expect(MalParsers::FetchEntry)
          .to have_received(:perform_async)
          .with(entries.first[:id], entries.first[:type])
          .exactly(entries_count).times
      end
    end
  end
end
