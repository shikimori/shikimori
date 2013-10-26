
require 'spec_helper'

describe PersonMalParser do
  before (:each) { SiteParserWithCache.stub(:load_cache).and_return(:list => {}) }

  let (:parser) {
    p = PersonMalParser.new
    p.stub(:save_cache)
    p
  }

  let (:person_id) { 1 }

  it 'have correct type' do
    parser.instance_eval { type }.should == 'person'
  end

  it 'fetches person data' do
    data = parser.fetch_entry_data(person_id)
    data[:name].should == 'Tomokazu Seki'
    data.should include(:img)
    data.should include(:given_name)
    data.should include(:family_name)
    data.should include(:japanese)
    data.should include(:birthday)
  end

  it 'fetches person images' do
    images = parser.fetch_entry_pictures(person_id)
    images.should have(5).items
  end

  it 'fetches the whole entry' do
    parser.fetch_entry(person_id).should have(2).items
  end

  describe 'import' do
    before (:each) {
      FactoryGirl.create :person, :id => 1
      FactoryGirl.create :person, :id => 2, :imported_at => DateTime.now
    }

    it 'prepares' do
      parser.prepare.should have(1).item
    end

    it 'imports' do
      FactoryGirl.create :person_role, :person_id => 3
      FactoryGirl.create :person_role, :person_id => 4
      expect {
        parser.import.should have(3).items
      }.to change(Person, :count).by(2)
    end
  end
end
