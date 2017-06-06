describe Elasticsearch::Config do
  let(:config) { Elasticsearch::Config.instance }

  it do
    expect(config.config.keys).to eq %i[
      analysis
      default_type_mappings
      name_properties
      mappings
    ]
  end

  describe '[]' do
    it do
      expect(config[:mappings]).to be_a Hash
    end
  end
end
