
require 'spec_helper'

describe CharacterMalParser do
  before (:each) { SiteParserWithCache.stub(:load_cache).and_return({list: {}}) }

  let (:parser) {
    p = CharacterMalParser.new
    p.stub(:save_cache)
    p
  }

  let(:character_id) { 35662 }

  it 'have correct type' do
    parser.instance_eval { type }.should == 'character'
  end

  it 'fetches character data' do
    data = parser.fetch_entry_data(character_id)
    data[:name].should == 'Charlotte Dunois'
    data[:fullname].should == 'Charlotte "Charles, Charl" Dunois'
    data[:description_mal].should include('[spoiler]')

    data[:seyu].should have(2).item
    data[:seyu].first.should == { role: 'Japanese', id: 185 }

    data.should include(:img)
  end

  it 'fetches character images' do
    images = parser.fetch_entry_pictures(character_id)
    images.should have(7).items
  end

  it 'fetches the whole entry' do
    parser.fetch_entry(character_id).should have(2).items
  end

  describe 'import' do
    before {
      create :character, id: 8177
      create :character, id: 26201, imported_at: DateTime.now
    }

    it 'prepare' do
      parser.prepare.should have(1).item
    end

    it 'import' do
      FactoryGirl.create :person_role, character_id: 1
      FactoryGirl.create :person_role, character_id: 2

      expect {
        parser.import.should have(3).items
      }.to change(Character, :count).by(2)
    end

    it 'import seyu' do
      FactoryGirl.create :person_role, character_id: 1

      expect {
        parser.import
      }.to change(PersonRole, :count).by_at_least(8)
    end
  end
end
