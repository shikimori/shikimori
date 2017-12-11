describe UsersIndex, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    UsersIndex.purge!
  end

  let(:url) do
    format(
      'http://localhost:9200/shikimori_test_users/_analyze'\
        "?analyzer=#{analyzer}"\
        "&text=#{text}"
    )
  end
  subject do
    JSON.parse(
      open(url).read, symbolize_names: true
    )[:tokens].map { |v| v[:token] }
  end

  context 'original_analyzer' do
    let(:analyzer) { 'original_analyzer' }
    let(:text) { 'Test Zxc' }
    it { is_expected.to eq ['test zxc'] }
  end

  context 'edge_analyzer' do
    let(:analyzer) { 'edge_analyzer' }

    context 'one word' do
      let(:text) { 'test' }
      it { is_expected.to eq %w[t te tes test] }
    end

    context 'two words' do
      let(:text) { 'te st' }
      it { is_expected.to eq %w[t te s st] }
    end

    context 'same words' do
      let(:text) { 'tes tes' }
      it { is_expected.to eq %w[t te tes t te tes] }
    end
  end

  context 'ngram_analyzer' do
    let(:analyzer) { 'ngram_analyzer' }

    context 'one word' do
      let(:text) { 'test' }
      it { is_expected.to eq %w[t te tes test e es est s st] }
    end

    context 'two words' do
      let(:text) { 'te st' }
      it { is_expected.to eq %w[t te e s st t] }
    end

    context 'same words' do
      let(:text) { 'tes tes' }
      it { is_expected.to eq %w[t te tes e es s t te tes e es s] }
    end
  end

  context 'search_analyzer' do
    let(:analyzer) { 'search_analyzer' }

    context 'one word' do
      let(:text) { 'test' }
      it { is_expected.to eq %w[test] }
    end

    context 'two words' do
      let(:text) { 'te st' }
      it { is_expected.to eq %w[te st] }
    end

    context 'same words' do
      let(:text) { 'tes tes' }
      it { is_expected.to eq %w[tes tes] }
    end
  end
end
