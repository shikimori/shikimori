describe UserListParsers::AnimePlanetListParser, vcr: { cassette_name: 'anime_planet' } do
  let(:parser) { UserListParsers::AnimePlanetListParser.new klass, wont_watch_strategy }
  let(:login) { 'shikitest' }
  let(:wont_watch_strategy) { nil }
  subject(:parsed) { parser.parse login }

  context 'anime' do
    let(:klass) { Anime }
    let!(:anime_1) { create :anime, name: 'Black Bullet' }
    let!(:anime_2) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2007-01-01') }
    let!(:anime_3) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2008-01-01') }

    context 'without wont watch' do
      it 'properly parsed' do
        expect(parsed.size).to eq(6)

        expect(parsed[0]).to eq(name: "Attack on Titan", status: UserRate.status_id(:completed), score: 4.0, year: 2013, episodes: 25, id: nil)
        expect(parsed[1]).to eq(name: "Black Bullet", id: anime_1.id, status: UserRate.status_id(:dropped), score: 4.0, episodes: 5, year: 2014)
        expect(parsed[2]).to eq(name: "Naruto Shippuden", id: nil, status: nil, score: 0.0, episodes: 0, year: 2007)
        expect(parsed[3]).to eq(name: "No Game No Life", id: nil, status: UserRate.status_id(:on_hold), score: 4.0, episodes: 3, year: 2014)
        expect(parsed[4]).to eq(name: "Zombie-Loan", id: anime_2.id, status: UserRate.status_id(:planned), score: 0.0, episodes: 0, year: 2007)
        expect(parsed[5]).to eq(name: "Zombie-Loan Specials", id: nil, status: UserRate.status_id(:watching), score: 7.0, episodes: 1, year: 2008)
      end
    end

    context 'with wont watch' do
      let(:wont_watch_strategy) { UserRate.status_id :dropped }
      it 'properly parsed' do
        expect(parsed.size).to eq(6)

        expect(parsed[0]).to eq(name: "Attack on Titan", status: UserRate.status_id(:completed), score: 4.0, year: 2013, episodes: 25, id: nil)
        expect(parsed[1]).to eq(name: "Black Bullet", id: anime_1.id, status: UserRate.status_id(:dropped), score: 4.0, episodes: 5, year: 2014)
        expect(parsed[2]).to eq(name: "Naruto Shippuden", id: nil, status: wont_watch_strategy, score: 0.0, episodes: 0, year: 2007)
        expect(parsed[3]).to eq(name: "No Game No Life", id: nil, status: UserRate.status_id(:on_hold), score: 4.0, episodes: 3, year: 2014)
        expect(parsed[4]).to eq(name: "Zombie-Loan", id: anime_2.id, status: UserRate.status_id(:planned), score: 0.0, episodes: 0, year: 2007)
        expect(parsed[5]).to eq(name: "Zombie-Loan Specials", id: nil, status: UserRate.status_id(:watching), score: 7.0, episodes: 1, year: 2008)
      end
    end
  end

  context 'manga' do
    let(:klass) { Manga }
    let!(:manga) { create :manga, name: 'Maid Sama!' }

    it 'properly parsed' do
      expect(parsed.size).to eq(1)
      expect(parsed[0]).to eq(name: "Maid Sama!", status: 2, score: 6.0, year: 2005, volumes: 18, chapters: 0, id: manga.id)
    end
  end
end
