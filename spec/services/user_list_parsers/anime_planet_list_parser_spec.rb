require 'spec_helper'

describe UserListParsers::AnimePlanetListParser do
  let(:parser) { UserListParsers::AnimePlanetListParser.new klass }
  let(:login) { 'shikitest' }
  subject(:parsed) { parser.parse login }

  context :anime do
    let(:klass) { Anime }
    let!(:anime_1) { create :anime, name: 'Black Bullet' }
    let!(:anime_2) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2007-01-01') }
    let!(:anime_3) { create :anime, name: 'Zombie-Loan', aired_on: Date.parse('2008-01-01') }

    it 'parsed data' do
      expect(parsed).to have(5).items
      expect(parsed[0]).to eq(name: "Black Bullet", id: anime_1.id, status: 4, score: 4.0, episodes: 5, year: 2014)
      expect(parsed[1]).to eq(name: "Naruto Shippuden", id: nil, status: nil, score: 0.0, episodes: 0, year: 2007)
      expect(parsed[2]).to eq(name: "No Game No Life", id: nil, status: 3, score: 4.0, episodes: 3, year: 2014)
      expect(parsed[3]).to eq(name: "Zombie-Loan", id: anime_2.id, status: 0, score: 0.0, episodes: 0, year: 2007)
      expect(parsed[4]).to eq(name: "Zombie-Loan Specials", id: nil, status: 1, score: 7.0, episodes: 1, year: 2008)
    end
  end

  context :manga do
    let(:klass) { Manga }
    let!(:manga) { create :manga, name: 'Maid Sama!' }

    it 'parsed data' do
      expect(parsed).to have(1).item
      expect(parsed[0]).to eq(name: "Maid Sama!", status: 2, score: 6.0, year: 2005, volumes: 18, chapters: 0, id: manga.id)
    end
  end
end
