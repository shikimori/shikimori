#describe Tags::ImportDanbooruTags, vcr: { cassette_name: 'danbooru' } do
  #let(:importer) { Tags::ImportDanbooruTags.new }

  #before { allow(importer).to receive(:import_page).with(:danbooru, 1, Tags::ImportDanbooruTags::LIMIT) }
  #before { allow(importer).to receive(:import_page).with(:danbooru, 2, Tags::ImportDanbooruTags::LIMIT) }

  #subject(:import) { Tags::ImportDanbooruTags.new.do_import }

  #it { expect{import}.to change(DanbooruTag, :count).by(2 * Tags::ImportDanbooruTags::LIMIT) }

  #describe 'import only new tags' do
    #before { import }
    #it { expect{importer.send :import_page, :danbooru, 2, Tags::ImportDanbooruTags::LIMIT + 1}.to change(DanbooruTag, :count).by(999) }
  #end
#end
