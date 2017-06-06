describe Elasticsearch::Query::Ranobe do
  let(:service) { Elasticsearch::Query::Ranobe.new phrase: phrase, limit: limit }

  describe '#call', :vcr do
    let(:phrase) { 'utsuro' }
    let(:limit) { 10 }

    subject { service.call }

    it { is_expected.to have(2).items }
  end
end
