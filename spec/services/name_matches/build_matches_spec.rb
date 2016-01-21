describe NameMatches::BuildMatches do
  let(:service) { NameMatches::BuildMatches.new entry }
  let(:entry) do
    build_stubbed :anime,
      :tv,
      id: 136,
      name: 'My anime',
      synonyms: [
        'My little anime',
        'My : little anime',
        'My Little Anime',
        'MyAnim'
      ]
  end

  describe '#call' do
    subject(:name_matches) { service.call }
    it do
      is_expected.to have(9).items
      expect(name_matches.first).to be_kind_of NameMatch
      expect(name_matches.first).to be_new_record
      expect(name_matches.first).to have_attributes(
        id: nil,
        phrase: 'охотникхохотниктв1',
        group: 0,
        target: entry
      )
      expect(name_matches.second).to have_attributes(
        id: nil,
        phrase: 'myanime',
        group: 1,
        target: entry
      )
    end
  end
end
