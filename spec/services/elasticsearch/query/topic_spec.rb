describe Elasticsearch::Query::Topic do
  let(:service) do
    Elasticsearch::Query::Topic.new(
      phrase: phrase,
      locale: locale,
      forum_id: forum_id,
      limit: limit
    )
  end

  describe '#call', :vcr do
    let(:phrase) { 'kai' }
    let(:locale) { 'ru' }
    let(:forum_id) { 1 }
    let(:limit) { 10 }

    subject { service.call }

    it { is_expected.to have(limit).items }
  end
end
