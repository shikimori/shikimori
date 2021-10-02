describe Mal::ProcessDescription do
  subject { described_class.call value, type, id }

  let(:type) { 'anime' }
  let(:id) { 123 }

  context 'no text' do
    let(:value) { '' }
    it { is_expected.to be_nil }
  end

  context 'without source' do
    let(:value) { 'foo' }
    it do
      is_expected.to eq(
        'foo[source]http://myanimelist.net/anime/123[/source]'
      )
    end
  end

  context 'with empty source' do
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
