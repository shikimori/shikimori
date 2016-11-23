describe Elasticsearch::Config do
  let(:config) { Elasticsearch::Config.instance }

  describe '[]' do
    it { expect(config[:version]).to be_kind_of Numeric }
    it { expect(config[:anime]).to be_kind_of Hash }
  end
end
