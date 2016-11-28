describe Elasticsearch::Query::User do
  let(:service) { Elasticsearch::Query::User.new phrase: phrase, limit: limit }

  describe '#call', :vcr do
    let(:phrase) { 'morr' }
    let(:limit) { 10 }

    subject { service.call }

    it { is_expected.to have(limit).items }
  end
end
