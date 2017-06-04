describe Elasticsearch::Query::Collection do
  let(:service) do
    Elasticsearch::Query::Collection.new(
      phrase: phrase,
      locale: locale,
      limit: limit
    )
  end

  describe '#call', :vcr do
    let(:phrase) { 'ани' }
    let(:locale) { 'ru' }
    let(:limit) { 10 }

    subject { service.call }

    it { is_expected.to have(limit).items }
  end
end
