describe Tags::CoubConfig do
  let(:config) { described_class.new }

  describe '#ignored_tags' do
    it { expect(config.ignored_tags).to eq config.custom_ignored_tags + config.auto_ignored_tags }
  end

  describe '#custom_ignored_tags' do
    it { expect(config.custom_ignored_tags).to have_at_least(300).items }
  end

  describe '#auto_ignored_tags' do
    it { expect(config.auto_ignored_tags).to have_at_least(1000).items }
  end

  describe '#added_tags' do
    it { expect(config.added_tags).to have_at_least(2).items }
  end
end
