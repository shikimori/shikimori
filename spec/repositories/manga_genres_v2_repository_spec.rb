describe MangaGenresV2Repository do
  let(:query) { described_class.instance }

  before { query.reset }

  it { expect(query).to be_kind_of RepositoryBase }

  describe '[]' do
    let!(:anime_genre) { create :genre_v2, :anime }
    let!(:manga_genre) { create :genre_v2, :manga }

    it do
      expect(query[anime_genre.id]).to eq nil
      expect(query[manga_genre.id]).to eq manga_genre
    end
  end
end
