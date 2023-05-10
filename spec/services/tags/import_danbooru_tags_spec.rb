describe Tags::ImportDanbooruTags, :vcr do
  let(:service) { described_class.new }

  before do
    allow(service)
      .to receive(:import_page)
      .with(:danbooru, 1, described_class::LIMIT)
      .and_call_original

    allow(service)
      .to receive(:import_page)
      .with(:danbooru, 2, described_class::LIMIT)
      .and_call_original

    allow(service)
      .to receive(:import_page)
      .with(:danbooru, 3, described_class::LIMIT)
      .and_return(0)

    allow(service)
      .to receive(:import_page)
      .with(:konachan, nil, nil)
      .and_call_original
  end

  subject { service.call }

  it do
    expect { subject }
      .to change(DanbooruTag, :count)
      .by((2 * Tags::ImportDanbooruTags::LIMIT) + described_class::KONACHAN_LIMIT)
    expect(service).to have_received(:import_page).exactly(4).times
  end

  # describe 'import only new tags' do
  #   before { import }
  #   it do
  #     expect { service.send :import_page, :danbooru, 2, Tags::ImportDanbooruTags::LIMIT + 1 }.to change(DanbooruTag, :count).by(999)
  #   end
  # end
end
