describe DbEntries::ProcessDescription do
  subject { service.call value, type, id }
  let(:service) { described_class.new }

  let(:type) { 'anime' }
  let(:id) { 123 }

  context 'without source' do
    let(:value) { 'foo' }
    it do
      is_expected.to eq(
        'foo[source]http://myanimelist.net/anime/123[/source]'
      )
    end
  end

  context 'with empt source' do
    let(:value) { 'foo[source][/source]' }
    it do
      is_expected.to eq(
        'foo[source]http://myanimelist.net/anime/123[/source]'
      )
    end
  end

  context 'with source' do
    let(:value) { 'foo[source]bar[/source]' }
    it do
      is_expected.to eq('foo[source]bar[/source]')
    end
  end

  context 'with source ANN' do
    let(:value) { 'foo[source]ANN[/source]' }
    it do
      is_expected.to eq('foo[source]animenewsnetwork.com[/source]')
    end
  end
end
