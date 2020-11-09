describe ApplicationIndex, :vcr do
  # include_context :disable_vcr
  include_context :chewy_indexes, %i[animes clubs]
  # include_context :chewy_logger

  let(:url) { "http://localhost:9200/shikimori_test_#{type}/_analyze" }
  let(:type) { :clubs }
  let(:response) do
    Faraday
      .get do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = {
          analyzer: analyzer,
          text: text
        }.to_json
      end
      .body
  end

  let(:text) { 'Kai wa-sama' }

  subject do
    JSON.parse(response, symbolize_names: true)[:tokens].pluck(:token)
  end

  context 'original_analyzer' do
    let(:analyzer) { :original_analyzer }

    it do
      is_expected.to eq [
        'kai wa sama'
      ]
    end
  end

  context 'edge_phrase_analyzer' do
    let(:analyzer) { :edge_phrase_analyzer }

    it do
      is_expected.to eq [
        'k',
        'ka',
        'kai',
        'kai ',
        'kai w',
        'kai wa',
        'kai wa ',
        'kai wa s',
        'kai wa sa',
        'kai wa sam',
        'kai wa sama'
      ]
    end

    context 'one word' do
      let(:text) { 'test' }
      it { is_expected.to eq %w[t te tes test] }
    end

    context 'two words' do
      let(:text) { 'te st' }
      it do
        is_expected.to eq [
          't',
          'te',
          'te ',
          'te s',
          'te st'
        ]
      end
    end

    context 'same words' do
      let(:text) { 'tes tes' }
      it do
        is_expected.to eq [
          't',
          'te',
          'tes',
          'tes ',
          'tes t',
          'tes te',
          'tes tes'
        ]
      end
    end
  end

  context 'edge_word_analyzer' do
    let(:analyzer) { :edge_word_analyzer }

    it do
      is_expected.to eq [
        'k',
        'ka',
        'kai',
        'w',
        'wa',
        's',
        'sa',
        'sam',
        'sama'
      ]
    end

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
    let(:analyzer) { :ngram_analyzer }

    it do
      is_expected.to eq [
        'k',
        'ka',
        'kai',
        'a',
        'ai',
        'i',
        'w',
        'wa',
        'a',
        's',
        'sa',
        'sam',
        'sama',
        'a',
        'am',
        'ama',
        'm',
        'ma'
      ]
    end

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

  context 'search_phrase_analyzer' do
    let(:analyzer) { :search_phrase_analyzer }

    it do
      is_expected.to eq [
        'kai wa sama'
      ]
    end

    context 'one word' do
      let(:text) { 'test' }
      it { is_expected.to eq ['test'] }
    end

    context 'two words' do
      let(:text) { 'te st' }
      it { is_expected.to eq ['te st'] }
    end

    context 'same words' do
      let(:text) { 'tes tes' }
      it { is_expected.to eq ['tes tes'] }
    end
  end

  context 'search_word_analyzer' do
    let(:analyzer) { :search_word_analyzer }

    it do
      is_expected.to eq [
        'kai',
        'wa',
        'sama'
      ]
    end

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

  context 'japanese translit subject' do
    let(:analyzer) { :original_analyzer }

    context 'clubs' do
      context 'lowercase' do
        let(:text) { 'bio' }
        it { is_expected.to eq %w[bio] }
      end

      context 'uppercase' do
        let(:text) { 'Bio' }
        it { is_expected.to eq %w[bio] }
      end
    end

    context 'animes' do
      let(:type) { :animes }

      context 'lowercase' do
        let(:text) { 'bio' }
        it { is_expected.to eq %w[beo] }
      end

      context 'uppercase' do
        let(:text) { 'Bio' }
        it { is_expected.to eq %w[beo] }
      end
    end
  end
end
