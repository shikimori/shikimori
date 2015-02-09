describe CharacterMalParser, vcr: { cassette_name: 'character_mal_parser' } do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return(list: {}) }
  before { allow(parser).to receive :save_cache }

  let(:parser) { CharacterMalParser.new }
  let(:character_id) { 35662 }

  it 'have correct type' do
    expect(parser.instance_eval { type }).to eq('character')
  end

  it 'fetches character data' do
    data = parser.fetch_entry_data(character_id)
    expect(data[:name]).to eq('Charlotte Dunois')
    expect(data[:fullname]).to eq('Charlotte "Charles, Charl" Dunois')
    expect(data[:description_mal]).to include('[spoiler]')

    expect(data[:seyu].size).to eq(2)
    expect(data[:seyu].first).to eq({ role: 'Japanese', id: 185 })

    expect(data[:img]).to eq 'http://cdn.myanimelist.net/images/characters/8/216587.jpg'
  end

  it 'fetches character images' do
    images = parser.fetch_entry_pictures(character_id)
    expect(images.size).to eq(7)
  end

  it 'fetches the whole entry' do
    expect(parser.fetch_entry(character_id).size).to eq(2)
  end

  describe 'import' do
    let!(:character_1) { create :character, :with_thread, id: 8177 }
    let!(:character_2) { create :character, :with_thread, id: 26201, imported_at: Time.zone.now }

    it { expect(parser.prepare.size).to eq(1) }

    it 'import' do
      create :person_role, character_id: 1
      create :person_role, character_id: 2

      expect {
        expect(parser.import.size).to eq(3)
      }.to change(Character, :count).by(2)
    end

    it 'import seyu' do
      create :person_role, character_id: 1

      expect {
        parser.import
      }.to change(PersonRole, :count).by_at_least(8)
    end
  end
end
