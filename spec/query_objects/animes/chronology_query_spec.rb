describe Animes::ChronologyQuery do
  let(:query) { described_class }

  before { Animes::BannedRelations.instance.clear_cache! }
  after(:all) { Animes::BannedRelations.instance.clear_cache! }

  let(:anime_1) { create :anime, id: 1, aired_on: 1.year.ago }
  let(:anime_2) { create :anime, id: 2, aired_on: 2.years.ago }
  let(:anime_3) { create :anime, id: 3, aired_on: 3.years.ago }

  let!(:related_1_2) { create :related_anime, source_id: anime_1.id, anime_id: anime_2.id }
  let!(:related_2_1) { create :related_anime, source_id: anime_2.id, anime_id: anime_1.id }

  let!(:related_2_3) { create :related_anime, source_id: anime_2.id, anime_id: anime_3.id }
  let!(:related_3_2) { create :related_anime, source_id: anime_3.id, anime_id: anime_2.id }

  describe '#links' do
    describe 'direct ban' do
      before do
        allow(Animes::BannedRelations.instance).to receive(:cache)
          .and_return animes: [[anime_2.id, anime_3.id]]
      end

      it { expect(query.new(anime_1).links).to eq [related_1_2, related_2_1] }
    end

    describe 'indirect ban does not work anymore' do
      before do
        allow(Animes::BannedRelations.instance).to receive(:cache)
          .and_return animes: [[anime_1.id, anime_3.id]]
      end

      it do
        expect(query.new(anime_1).links).to eq [
          related_1_2,
          related_2_1,
          related_2_3,
          related_3_2
        ]
      end
    end
  end

  describe '#fetch' do
    describe 'direct ban' do
      before do
        allow(Animes::BannedRelations.instance).to receive(:cache)
          .and_return animes: [[anime_1.id, anime_2.id]]
      end

      it do
        expect(query.new(anime_1).fetch).to eq [anime_1]
        expect(query.new(anime_2).fetch).to eq [anime_2, anime_3]
        expect(query.new(anime_3).fetch).to eq [anime_2, anime_3]
      end
    end

    describe 'indirect ban does not work anymore' do
      before do
        allow(Animes::BannedRelations.instance).to receive(:cache)
          .and_return animes: [[anime_1.id, anime_3.id]]
      end

      it do
        expect(query.new(anime_1).fetch).to eq [anime_1, anime_2, anime_3]
        expect(query.new(anime_2).fetch).to eq [anime_1, anime_2, anime_3]
        expect(query.new(anime_3).fetch).to eq [anime_1, anime_2, anime_3]
      end
    end

    describe '* ban' do
      before do
        allow(Animes::BannedRelations.instance).to receive(:cache)
          .and_return animes: [[anime_1.id, '*']]
      end

      it do
        expect(query.new(anime_1).fetch).to eq [anime_1]
        expect(query.new(anime_2).fetch).to eq [anime_2, anime_3]
        expect(query.new(anime_3).fetch).to eq [anime_2, anime_3]
      end
    end
  end
end
