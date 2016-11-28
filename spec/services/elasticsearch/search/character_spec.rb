describe Elasticsearch::Search::Character do
  let(:service) { Elasticsearch::Search::Character.new phrase: phrase, limit: limit }

  describe '#call', :vcr do
    let(:phrase) { 'nana' }
    let(:limit) { 10 }

    subject { service.call }

    it { is_expected.to have(limit).items }
  end
end
