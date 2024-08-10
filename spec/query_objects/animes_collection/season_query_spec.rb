describe AnimesCollection::SeasonQuery do
  let(:query) do
    AnimesCollection::SeasonQuery.new(
      klass:,
      filters:,
      user: nil,
      limit: 20
    )
  end
  let(:klass) { Anime }

  describe '#call' do
    subject(:page) { query.call }

    let!(:anime_1) { create :anime, :tv, ranked: 1, aired_on: Date.parse('10-10-2016') }
    let!(:anime_2) { create :anime, :tv, ranked: 1, aired_on: Date.parse('10-10-2017') }
    let!(:anime_3) { create :anime, :ova, ranked: 2, aired_on: Date.parse('10-10-2016') }
    let!(:anime_4) { create :anime, :ona, ranked: 3, aired_on: Date.parse('10-10-2016') }
    let!(:manga) { create :manga }

    let(:filters) do
      {
        season: 'fall_2016',
        order: AnimesCollection::View::DEFAULT_ORDER
      }
    end

    it do
      is_expected.to have_attributes(
        collection: [anime_1, anime_3, anime_4],
        page: 1,
        pages_count: 1
      )
    end
  end
end
