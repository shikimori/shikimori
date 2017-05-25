describe GenerateCopyrightedIds, vcr: { cassette_name: 'GenerateCopyrightedIds' } do
  let(:service) { GenerateCopyrightedIds.new }

  describe '#copyrighted_entries' do
    before { allow(service).to receive(:total_pages).and_return 1 }
    subject { service.copyrighted_entries }

    it do
      is_expected.to eq(
        anime: %w[369 32995 2964 30831 11887 13655 145 1846 11241],
        manga: %w[14483],
        ranobe: %w[14483],
        person: %w[5572]
      )
    end
  end

  describe '#all_links' do
    before { allow(service).to receive(:total_pages).and_return 2 }
    subject { service.all_links }

    it do
      is_expected.to have(31).items
      expect(subject.first)
        .to eq 'http://shikimori.org/animes/369-boogiepop-wa-warawanai-boogiepop-phantom.html'
    end
  end

  describe '#page_links' do
    subject { service.page_links 1 }

    it do
      is_expected.to have(14).items
      expect(subject.first)
        .to eq 'http://shikimori.org/animes/369-boogiepop-wa-warawanai-boogiepop-phantom.html'
    end
  end

  describe '#total_pages' do
    subject { service.total_pages }
    it { is_expected.to eq 51 }
  end
end
