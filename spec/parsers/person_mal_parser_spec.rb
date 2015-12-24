describe PersonMalParser, vcr: { cassette_name: 'person_mal_parser' } do
  before (:each) { allow(SiteParserWithCache).to receive(:load_cache).and_return(list: {}) }

  let (:parser) {
    p = PersonMalParser.new
    allow(p).to receive(:save_cache)
    p
  }

  let(:person_id) { 1 }

  it 'have correct type' do
    expect(parser.instance_eval { type }).to eq('person')
  end

  it 'fetches person data' do
    data = parser.fetch_entry_data(person_id)
    expect(data[:name]).to eq 'Tomokazu Seki'
    expect(data[:img]).to eq 'http://cdn.myanimelist.net/images/voiceactors/3/17141.jpg'
    expect(data).to include :given_name
    expect(data).to include :family_name
    expect(data).to include :japanese
    expect(data).to include :birthday
  end

  it 'fetches the whole entry' do
    expect(parser.fetch_entry(person_id)).to have(1).item
  end

  describe 'import' do
    let!(:person_1) { create :person, id: 1 }
    let!(:person_2) { create :person, id: 2, imported_at: Time.zone.now }

    it { expect(parser.prepare.size).to eq(1) }

    #it 'imports' do
      #create :person_role, person_id: 3
      #create :person_role, person_id: 4
      #expect {
        #parser.import.should have(3).items
      #}.to change(Person, :count).by(2)
    #end
  end
end
