describe ChronologyQuery do
  let(:anime1) { create :anime, kind: 'Special' }
  let(:anime2) { create :anime }
  let(:anime3) { create :anime }
  let(:anime4) { create :anime, id: 6115 }
  let(:anime5) { create :anime }

  before do
    create :related_anime, source_id: anime1.id, anime_id: anime2.id
    create :related_anime, source_id: anime2.id, anime_id: anime1.id

    create :related_anime, source_id: anime2.id, anime_id: anime3.id
    create :related_anime, source_id: anime3.id, anime_id: anime2.id

    create :related_anime, source_id: anime2.id, anime_id: anime4.id
    create :related_anime, source_id: anime4.id, anime_id: anime2.id

    create :related_anime, source_id: anime4.id, anime_id: anime5.id
    create :related_anime, source_id: anime5.id, anime_id: anime4.id
  end

  describe 'fetch' do
    describe 'with specials' do
      it { expect(ChronologyQuery.new(anime2, true).fetch.size).to eq(4) }
    end

    describe 'without specials' do
      it { expect(ChronologyQuery.new(anime2, false).fetch.size).to eq(3) }
    end
  end
end
