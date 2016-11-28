describe Autocomplete::User do
  subject(:query) do
    Autocomplete::User.call(
      scope: scope,
      phrase: phrase
    )
  end

  describe '#call' do
    let(:scope) { User.all }
    let(:phrase) { 'Kaichou' }

    let(:user) { build_stubbed :user }

    before do
      allow(Search::User).to receive(:call)
        .with(phrase: phrase, scope: scope, ids_limit: Autocomplete::User::LIMIT)
        .and_return [user]
    end

    it do
      is_expected.to eq [user]
    end
  end
end
