describe CharactersQuery do
  let(:character) { create :character, name: 'test' }
  let(:query) { CharactersQuery.new }
  before do
    create :character, name: 'testZzz'
    character
    create :anime, characters: [character]
    create :character, japanese: 'シュタ インズ'
    create :character, name: 'qwert', russian: 'яяяя'
  end

  describe 'fill_works' do
    before { 1.upto(6) { create :anime, characters: [character] } }
    let(:fetched_query) { query.fill_works query.fetch }

    it { expect(fetched_query.first.best_works.size).to eq(CharactersQuery::WORKS_LIMIT) }
    it { expect(fetched_query.first.last_works.size).to eq(CharactersQuery::WORKS_LIMIT) }
  end
end
