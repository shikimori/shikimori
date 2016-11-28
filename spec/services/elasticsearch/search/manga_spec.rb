describe Elasticsearch::Search::Manga do
  let(:service) { Elasticsearch::Search::Manga.new phrase: phrase, limit: limit }

  describe '#call', :vcr do
    let(:phrase) { 'kai' }
    let(:limit) { 10 }

    subject { service.call }

    it { is_expected.to have(limit).items }
  end
end
