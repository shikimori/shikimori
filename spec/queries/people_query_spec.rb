require 'spec_helper'

describe PeopleQuery do
  let(:person) { create :person, name: 'test', mangaka: true }
  let(:query) { PeopleQuery.new(search: 'test', kind: 'mangaka') }
  before do
    create :person, name: 'testZzz', mangaka: true
    person
    create :manga, people: [person]
    create :person, japanese: ['シュタインズ'], mangaka: true
    create :person, name: 'qwert'
  end

  describe 'fetch' do
    it { query.fetch.to_a.should have(2).items }

    it 'should be in correct order' do
      query.fetch.first.id.should eq person.id
    end
    it 'japanese search' do
      PeopleQuery.new(search: 'シュタインズ', kind: 'mangaka').fetch.to_a.should have(1).item
    end
  end

  describe 'fill_works' do
    before { 1.upto(6) { create :manga, people: [person] } }
    let(:fetched_query) { query.fill_works(query.fetch) }

    it { fetched_query.first.best_works.should have(PeopleQuery::WorksLimit).items }
    it { fetched_query.first.last_works.should have(PeopleQuery::WorksLimit).items }
  end

  describe 'is_producer' do
    it { PeopleQuery.new(search: 'test', kind: 'producer').producer?.should be_true }
    it { PeopleQuery.new(search: 'test', kind: 'mangaka').producer?.should be_false }
  end

  describe 'complete' do
    it { PeopleQuery.new(search: 'test', kind: 'mangaka').complete.should have(2).items }
    it { PeopleQuery.new(search: 'シュタインズ', kind: 'mangaka').complete.should have(1).item }
    it { PeopleQuery.new(search: 'qwert', kind: 'producer').complete.should have(0).items }
    it { PeopleQuery.new(search: 'qwert', kind: nil).complete.should have(1).item }
  end
end
