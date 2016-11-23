describe Elasticsearch::Search do
  let(:service) { Elasticsearch::Search.new phrase: phrase, type: type, limit: limit }
  subject { service.call }

  describe '#call', :vcr do
    let(:phrase) { 'kai' }
    let(:type) { :anime }
    let(:limit) { 10 }

    it do
      is_expected.to have(limit).items
    end
  end
end
