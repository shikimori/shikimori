describe Genres do
  let(:query) { Genres.instance }

  describe '[]' do
    let!(:genre) { create :genre }
    it do
      expect(query[genre.id]).to eq genre
    end
  end

  describe '#reset' do
    let(:genre_id) { 999_999_999 }

    it do
      expect(query[genre_id]).to be_nil
      genre = create :genre, id: genre_id
      expect(query[genre_id]).to be_nil

      query.reset

      expect(query[genre_id]).to eq genre
    end
  end
end
