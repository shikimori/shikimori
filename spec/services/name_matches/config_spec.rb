describe NameMatches::Config do
  let(:config) { NameMatches::Config.instance }

  describe '#bad_names' do
    it { expect(config.bad_names).to be_kind_of Regexp }
  end

  describe '#synonyms' do
    it { expect(config.synonyms).to have_at_least(30).items }
  end

  describe '#predefined_names' do
    it { expect(config.predefined_names Anime).to have_at_least(300).items }
    it { expect(config.predefined_names Manga).to have(1).item }
  end

  describe '#splitters' do
    it { expect(config.splitters).to have_at_least(2).items }
    it { expect(config.splitters.first).to be_kind_of Regexp }
  end
end
