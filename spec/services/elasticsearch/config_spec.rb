describe Elasticsearch::Config do
  let(:config) { Elasticsearch::Config.instance }

  describe '[]' do
    it { expect(config[:node]).to be_kind_of Hash }
  end
end
