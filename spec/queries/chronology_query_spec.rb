describe ChronologyQuery do
  let(:query) { ChronologyQuery }
  after { BannedRelations.instance.clear_cache! }

  before :all do
    raise 'rebel animes in database!' unless Anime.count.zero?
    RSpec::Mocks.with_temporary_scope do
      @anime_1 = create :anime, id: 1, aired_on: 1.years.ago
      @anime_2 = create :anime, id: 2, aired_on: 2.years.ago
      @anime_3 = create :anime, id: 3, aired_on: 3.years.ago
    end

    @related_1_2 = create :related_anime, source_id: @anime_1.id, anime_id: @anime_2.id
    @related_2_1 = create :related_anime, source_id: @anime_2.id, anime_id: @anime_1.id

    @related_2_3 = create :related_anime, source_id: @anime_2.id, anime_id: @anime_3.id
    @related_3_2 = create :related_anime, source_id: @anime_3.id, anime_id: @anime_2.id
  end

  describe '#relations' do
    before { allow(BannedRelations.instance).to receive(:cache)
      .and_return animes: [[@anime_1.id,@anime_3.id]] }

    it { expect(query.new(@anime_1).links).to eq [@related_1_2, @related_2_1] }
  end

  describe '#fetch' do
    describe 'direct ban' do
      before { allow(BannedRelations.instance).to receive(:cache)
        .and_return animes: [[@anime_1.id,@anime_2.id]] }

      it { expect(query.new(@anime_1).fetch.map(&:id)).to eq [@anime_1.id] }
      it { expect(query.new(@anime_2).fetch.map(&:id)).to eq [@anime_2.id, @anime_3.id] }
      it { expect(query.new(@anime_3).fetch.map(&:id)).to eq [@anime_2.id, @anime_3.id] }
    end


    describe 'indirect ban' do
      before { allow(BannedRelations.instance).to receive(:cache)
        .and_return animes: [[@anime_1.id,@anime_3.id]] }

      it { expect(query.new(@anime_1).fetch.map(&:id)).to eq [@anime_1.id, @anime_2.id] }
      it { expect(query.new(@anime_2).fetch.map(&:id)).to eq [@anime_1.id, @anime_2.id, @anime_3.id] }
      it { expect(query.new(@anime_3).fetch.map(&:id)).to eq [@anime_2.id, @anime_3.id] }
    end
  end
end
