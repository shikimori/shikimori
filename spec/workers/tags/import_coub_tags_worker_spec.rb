describe Tags::ImportCoubTagsWorker do
  before do
    allow(Tags::ImportCoubTags).to receive(:call).and_return tags
    allow(Tags::MatchCoubTags).to receive :call
  end
  let(:tags) { %w[naruto] }

  subject! { described_class.new.perform }

  it do
    expect(Tags::ImportCoubTags).to have_received :call
    expect(Tags::MatchCoubTags).to have_received(:call).with tags
  end
end
