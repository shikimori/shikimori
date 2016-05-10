describe AnimesCollection::SeasonQuery do
  let(:query) { AnimesCollection::SeasonQuery.new params, klass }
  let(:klass) { Anime }

  describe '#fetch' do
    subject(:page) { query.fetch }
    let!(:anime_1) { create :anime, :tv, ranked: 1, aired_on: Date.parse('10-10-2016') }
    let!(:anime_2) { create :anime, :tv, ranked: 1, aired_on: Date.parse('10-10-2017') }
    let!(:anime_3) { create :anime, :ova, ranked: 2, aired_on: Date.parse('10-10-2016') }
    let!(:anime_4) { create :anime, :ona, ranked: 3, aired_on: Date.parse('10-10-2016') }
    let!(:manga) { create :manga }

    let(:params) {{ season: 'fall_2016' }}

    it do
      is_expected.to have_attributes(
        collection: {
          'tv' => [anime_1],
          AnimesCollection::SeasonQuery::OVA_KEY => [anime_3, anime_4]
        },
        page: 1,
        pages_count: 1
      )
    end
  end
end
