describe ChronologyQuery do
  before :all do
    RSpec::Mocks.with_temporary_scope do
      @anime1 = create :anime, kind: 'Special'
      @anime2 = create :anime
      @anime3 = create :anime
      @anime4 = create :anime, id: 6115
      @anime5 = create :anime
    end

    create :related_anime, source_id: @anime1.id, anime_id: @anime2.id
    create :related_anime, source_id: @anime2.id, anime_id: @anime1.id

    create :related_anime, source_id: @anime2.id, anime_id: @anime3.id
    create :related_anime, source_id: @anime3.id, anime_id: @anime2.id

    create :related_anime, source_id: @anime2.id, anime_id: @anime4.id
    create :related_anime, source_id: @anime4.id, anime_id: @anime2.id

    create :related_anime, source_id: @anime4.id, anime_id: @anime5.id
    create :related_anime, source_id: @anime5.id, anime_id: @anime4.id
  end

  describe '#fetch' do
    subject { ChronologyQuery.new(anime, with_specials).fetch }
    let(:anime) { @anime2 }

    describe 'with specials' do
      let(:with_specials) { true }
      it { is_expected.to have(4).items }
    end

    describe 'without specials' do
      let(:with_specials) { false }
      it { is_expected.to have(3).items }
    end
  end
end
