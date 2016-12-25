describe Repos::MangaGenres do
  let(:query) { Repos::MangaGenres.instance }

  it { expect(query).to be_kind_of Repos::RepositoryBase }

  describe '[]' do
    let!(:anime_genre) { create :genre, :anime }
    let!(:manga_genre) { create :genre, :manga }

    it do
      expect(query[anime_genre.id]).to eq nil
      expect(query[manga_genre.id]).to eq manga_genre
    end
  end
end
