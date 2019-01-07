# describe Tags::ImportDanbooruTags, :vcr do
#   let(:service) { described_class.new }

#   # before do
#   #   allow(service)
#   #     .to receive(:import_page)
#   #     .with :danbooru, 1, Tags::ImportDanbooruTags::LIMIT

#   #   allow(service)
#   #     .to receive(:import_page)
#   #     .with :danbooru, 2, Tags::ImportDanbooruTags::LIMIT

#   #   allow(service)
#   #     .to receive(:import_page)
#   #     .with :konachan, nil, nil
#   # end

#   subject(:import) { service.call }

#   it do
#     expect { import }.to change(DanbooruTag, :count).by(2 * Tags::ImportDanbooruTags::LIMIT)
#   end

#   # describe 'import only new tags' do
#   #   before { import }
#   #   it do
#   #     expect { service.send :import_page, :danbooru, 2, Tags::ImportDanbooruTags::LIMIT + 1 }.to change(DanbooruTag, :count).by(999)
#   #   end
#   # end
# end
