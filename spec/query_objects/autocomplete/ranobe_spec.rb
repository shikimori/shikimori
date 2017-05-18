describe Autocomplete::Ranobe do
  subject(:query) do
    Autocomplete::Ranobe.call(
      scope: scope,
      phrase: phrase
    )
  end

  describe '#call' do
    let(:scope) { Ranobe.all }
    let(:phrase) { 'Kaichou' }

    let(:ranobe) { build_stubbed :ranobe }

    before do
      allow(Search::Ranobe).to receive(:call)
        .with(phrase: phrase, scope: scope, ids_limit: Autocomplete::Ranobe::LIMIT)
        .and_return [ranobe]
    end

    it do
      is_expected.to eq [ranobe]
    end
  end
end
