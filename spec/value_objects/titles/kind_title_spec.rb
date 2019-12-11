describe Titles::KindTitle do
  context 'anime' do
    let(:title) { Titles::KindTitle.new :tv, Anime }

    it { expect(title.text).to eq 'tv' }
    it { expect(title.url_params).to eq kind: 'tv' }
    it { expect(title.title).to eq 'TV Сериал' }
  end

  context 'manga' do
    let(:title) { Titles::KindTitle.new :doujin, Manga }

    it { expect(title.text).to eq 'doujin' }
    it { expect(title.url_params).to eq kind: 'doujin' }
    it { expect(title.title).to eq 'Додзинси' }
  end
end
