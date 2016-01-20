describe NameMatches::BuildMatches do
  let(:service) { NameMatches::BuildMatches.new entry }
  let(:entry) do
    build :anime,
      :tv,
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
    it { is_expected.to have(5).items }
  end
end
