describe PeopleQuery do
  let(:person) { create :person, name: 'test', mangaka: true }
  let(:query) { PeopleQuery.new(search: 'test', kind: 'mangaka') }
  before do
    create :person, name: 'testZzz', mangaka: true
    person
    create :manga, people: [person]
    create :person, japanese: 'シュタインズ', mangaka: true
    create :person, name: 'qwert'
  end

  describe 'fetch' do
    it { expect(query.fetch.to_a.size).to eq(2) }

    it 'should be in correct order' do
      expect(query.fetch.first.id).to eq person.id
    end
    it 'japanese search' do
      expect(PeopleQuery.new(search: 'シュタインズ', kind: 'mangaka').fetch.to_a.size).to eq(1)
    end
  end

  describe 'fill_works' do
    before { 1.upto(6) { create :manga, people: [person] } }
    let(:fetched_query) { query.fill_works(query.fetch) }

    it { expect(fetched_query.first.best_works.size).to eq(PeopleQuery::WorksLimit) }
    it { expect(fetched_query.first.last_works.size).to eq(PeopleQuery::WorksLimit) }
  end

  describe 'is_producer' do
    it { expect(PeopleQuery.new(search: 'test', kind: 'producer').producer?).to be_truthy }
    it { expect(PeopleQuery.new(search: 'test', kind: 'mangaka').producer?).to be_falsy }
  end

  describe 'complete' do
    it { expect(PeopleQuery.new(search: 'test', kind: 'mangaka').complete.size).to eq(2) }
    it { expect(PeopleQuery.new(search: 'シュタインズ', kind: 'mangaka').complete.size).to eq(1) }
    it { expect(PeopleQuery.new(search: 'qwert', kind: 'producer').complete.size).to eq(0) }
    it { expect(PeopleQuery.new(search: 'qwert', kind: nil).complete.size).to eq(1) }
  end
end
