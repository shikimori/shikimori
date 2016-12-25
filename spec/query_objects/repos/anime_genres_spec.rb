describe Repos::AnimeGenres do
  let(:query) { Repos::AnimeGenres.instance }

  it { expect(query).to be_kind_of Repos::RepositoryBase }

  describe '[]' do
    let!(:anime_genre) { create :genre, :anime }
    let!(:manga_genre) { create :genre, :manga }

    it do
      expect(query[anime_genre.id]).to eq anime_genre
      expect(query[manga_genre.id]).to eq nil
    end
  end
end
