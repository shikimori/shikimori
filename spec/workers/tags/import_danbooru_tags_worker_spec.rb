describe Tags::ImportDanbooruTagsWorker do
  before do
    allow(Tags::ImportDanbooruTags).to receive :call
    allow(Tags::MatchDanbooruTags).to receive :call
  end
  let(:tags) { %w[naruto] }

  subject! { described_class.new.perform }

  it do
    expect(Tags::ImportDanbooruTags).to have_received :call
    expect(Tags::MatchDanbooruTags).to have_received :call
  end
end
