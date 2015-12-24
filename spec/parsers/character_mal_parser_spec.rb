describe CharacterMalParser, vcr: { cassette_name: 'character_mal_parser' } do
  before { allow(SiteParserWithCache).to receive(:load_cache).and_return(list: {}) }
  before { allow(parser).to receive :save_cache }

  let(:parser) { CharacterMalParser.new }
  let(:character_id) { 35662 }

  it 'has correct type' do
    expect(parser.instance_eval { type }).to eq('character')
  end

  it 'fetches character data' do
    data = parser.fetch_entry_data(character_id)

    expect(data[:name]).to eq('Charlotte Dunois')
    expect(data[:fullname]).to eq('Charlotte "Charles, Charl" Dunois')
    expect(data[:description_en]).to include('[spoiler]')

    expect(data[:seyu].size).to eq(2)
    expect(data[:seyu].first).to eq({ role: 'Japanese', id: 185 })

    expect(data[:img]).to eq 'http://cdn.myanimelist.net/images/characters/8/216587.jpg'
  end

  it 'fetches the whole entry' do
    expect(parser.fetch_entry(character_id)).to have(1).item
  end

  it 'has correct image' do
    data = parser.fetch_entry_data 135627
    expect(data[:img]).to eq 'http://cdn.myanimelist.net/images/characters/14/296499.jpg'
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

  it 'correct synopsis' do
    data = parser.fetch_entry_data(87143)
    expect(data[:description_en]).to eq(
      "One of Kinana and Sumi's next door neighbors. She lives together with \
Oomori Hayase, whom she is in a romantic relationship with. She is the \
aggressive and socially hostile half of the couple. When embarrassed by \
Oomori, she often attacks her physically but she controls herself to \
the point of never actually doing physical damage.[br][br]Her clothing \
styles are a reference to the La Croix designs from \
[manga=6236]Alice Quartet[/manga]."
    )
  end

  it 'correct synopsis' do
    data = parser.fetch_entry_data(25023)

    expect(data[:description_en]).to eq(
      "Harui Kaho is a classmate of \
[character=21782]Kitagawa Mimi[/character]. There was once a time \
where Kaho did not go to school for a while. Mimi decided to visit her \
and found out that she was in love and was afraid to go out because of \
acne problems. With Mimi's help, Kaho was able to cure her \
acne and meet her date once again."
    )
  end
end
