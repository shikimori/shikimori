describe CharactersQuery do
  let(:character) { create :character, name: 'test' }
  let(:query) { CharactersQuery.new(search: 'test') }
  before do
    create :character, name: 'testZzz'
    character
    create :anime, characters: [character]
    create :character, japanese: 'シュタ インズ'
    create :character, name: 'qwert', russian: 'яяяя'
  end

  describe 'fetch' do
    it { expect(query.fetch.to_a.size).to eq(2) }
    it 'should be in correct order' do
      expect(query.fetch.first.id).to eq character.id
    end
    it 'japanese search' do
      expect(CharactersQuery.new(search: 'シュタ インズ').fetch.to_a.size).to eq(1)
    end
  end

  describe 'fill_works' do
    before { 1.upto(6) { create :anime, characters: [character] } }
    let(:fetched_query) { query.fill_works query.fetch }

    it { expect(fetched_query.first.best_works.size).to eq(CharactersQuery::WorksLimit) }
    it { expect(fetched_query.first.last_works.size).to eq(CharactersQuery::WorksLimit) }
  end

  describe 'complete' do
    it { expect(CharactersQuery.new(search: 'test').complete.size).to eq(2) }
    it { expect(CharactersQuery.new(search: 'シュタ インズ').complete.size).to eq(1) }
    it { expect(CharactersQuery.new(search: 'インズ シュタ').complete.size).to eq(1) }

    it { expect(CharactersQuery.new(search: 'シュタ イン').complete.size).to eq(1) }
    it { expect(CharactersQuery.new(search: 'インズ シュ').complete.size).to eq(1) }

    it { expect(CharactersQuery.new(search: 'яяяя').complete.size).to eq(1) }
  end
end
