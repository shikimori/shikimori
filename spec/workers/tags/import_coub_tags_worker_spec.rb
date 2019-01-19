describe Tags::ImportCoubTagsWorker do
  before do
    allow(Tags::CleanupIgnoredCoubTags).to receive :call
    allow(Tags::FetchCoubTags).to receive(:call).and_return tags
    allow(Tags::ImportCoubTags).to receive :call
    allow(Tags::MatchCoubTags).to receive :call
  end
  let(:tags) { %w[naruto] }

  subject! { described_class.new.perform }

  it do
    expect(Tags::CleanupIgnoredCoubTags).to have_received :call
    expect(Tags::FetchCoubTags).to have_received :call
    expect(Tags::ImportCoubTags).to have_received(:call).with tags
    expect(Tags::MatchCoubTags).to have_received(:call).with tags
  end
end
