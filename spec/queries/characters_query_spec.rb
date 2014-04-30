require 'spec_helper'

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
    it { query.fetch.to_a.should have(2).items }
    it 'should be in correct order' do
      query.fetch.first.id.should eq character.id
    end
    it 'japanese search' do
      CharactersQuery.new(search: 'シュタ インズ').fetch.to_a.should have(1).item
    end
  end

  describe 'fill_works' do
    before { 1.upto(6) { create :anime, characters: [character] } }
    let(:fetched_query) { query.fill_works query.fetch }

    it { fetched_query.first.best_works.should have(CharactersQuery::WorksLimit).items }
    it { fetched_query.first.last_works.should have(CharactersQuery::WorksLimit).items }
  end

  describe 'complete' do
    it { CharactersQuery.new(search: 'test').complete.should have(2).items }
    it { CharactersQuery.new(search: 'シュタ インズ').complete.should have(1).item }
    it { CharactersQuery.new(search: 'インズ シュタ').complete.should have(1).item }

    it { CharactersQuery.new(search: 'シュタ イン').complete.should have(1).item }
    it { CharactersQuery.new(search: 'インズ シュ').complete.should have(1).item }

    it { CharactersQuery.new(search: 'яяяя').complete.should have(1).item }
  end
end
