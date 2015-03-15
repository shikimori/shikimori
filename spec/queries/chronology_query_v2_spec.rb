describe ChronologyQueryV2 do
  let(:query) { ChronologyQueryV2 }

  before :all do
    RSpec::Mocks.with_temporary_scope do
      @anime1 = create :anime, id: 1, aired_on: 1.years.ago
      @anime2 = create :anime, id: 2, aired_on: 2.years.ago
      @anime3 = create :anime, id: 3, aired_on: 3.years.ago
    end

    create :related_anime, source_id: @anime1.id, anime_id: @anime2.id
    create :related_anime, source_id: @anime2.id, anime_id: @anime1.id

    create :related_anime, source_id: @anime2.id, anime_id: @anime3.id
    create :related_anime, source_id: @anime3.id, anime_id: @anime2.id
  end

  after { BannedRelations.instance.clear_cache! }

  describe '#fetch' do
    describe 'direct ban' do
      before { allow(BannedRelations.instance).to receive(:cache)
        .and_return animes: [[@anime1.id,@anime2.id]] }

      it { expect(query.new(@anime1).fetch.map(&:id)).to eq [@anime1.id] }
      it { expect(query.new(@anime2).fetch.map(&:id)).to eq [@anime2.id, @anime3.id] }
      it { expect(query.new(@anime3).fetch.map(&:id)).to eq [@anime2.id, @anime3.id] }
    end


    describe 'indirect ban' do
      before { allow(BannedRelations.instance).to receive(:cache)
        .and_return animes: [[@anime1.id,@anime3.id]] }

      it { expect(query.new(@anime1).fetch.map(&:id)).to eq [@anime1.id, @anime2.id] }
      it { expect(query.new(@anime2).fetch.map(&:id)).to eq [@anime1.id, @anime2.id, @anime3.id] }
      it { expect(query.new(@anime3).fetch.map(&:id)).to eq [@anime2.id, @anime3.id] }
    end
  end
end
