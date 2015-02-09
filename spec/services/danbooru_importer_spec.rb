#describe DanbooruImporter, vcr: { cassette_name: 'danbooru' } do
  #let(:importer) { DanbooruImporter.new }

  #before { allow(importer).to receive(:import_page).with(:danbooru, 1, DanbooruImporter::LIMIT) }
  #before { allow(importer).to receive(:import_page).with(:danbooru, 2, DanbooruImporter::LIMIT) }

  #subject(:import) { DanbooruImporter.new.do_import }

  #it { expect{import}.to change(DanbooruTag, :count).by(2 * DanbooruImporter::LIMIT) }

  #describe 'import only new tags' do
    #before { import }
    #it { expect{importer.send :import_page, :danbooru, 2, DanbooruImporter::LIMIT + 1}.to change(DanbooruTag, :count).by(999) }
  #end
#end
