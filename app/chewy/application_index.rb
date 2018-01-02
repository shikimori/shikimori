# посмотреть, на какие токены analyzer побил фразу
# curl -XGET 'http://localhost:9200/shikimori_development_users/_analyze?analyzer=ngram_analyzer' -d'gen_31_2958' | jq
# curl -XGET 'http://localhost:9200/shikimori_development_users/_analyze?analyzer=search_analyzer' -d'gen_31_2958' | jq

# посмотреть, на какие токены будет разбито значение, переданное в поле
# curl -XGET 'localhost:9200/shikimori_development_users/_analyze?field=sku.ngram' -d 'gen_31_2958' | jq
class ApplicationIndex < Chewy::Index
  ORIGINAL_ANALYZER = {
    type: 'custom',
    tokenizer: 'keyword',
    filter: %w[lowercase asciifolding]
  }
  EDGE_ANALYZER = {
    type: 'custom',
    tokenizer: 'standard',
    filter: %w[lowercase asciifolding edgeNGram_filter]
  }
  NGRAM_ANALYZER = {
    type: 'custom',
    tokenizer: 'standard',
    filter: %w[lowercase asciifolding nGram_filter distinct_words_filter]
  }
  SEARCH_ANALYZER = {
    type: 'custom',
    tokenizer: 'standard',
    filter: %w[lowercase asciifolding distinct_words_filter],
  }

  EDGE_NGRAM_TOKENIZER = {
    type: 'edgeNGram',
    min_gram: 1,
    max_gram: 30
  }

  EDGE_NGRAM_FILTER = {
    type: 'edgeNGram',
    min_gram: 1,
    max_gram: 30,
    side: 'front'
  }
  NGRAM_FILTER = {
    type: 'nGram',
    min_gram: 1,
    max_gram: 30
  }
  DISTINCT_WORDS_FILTER = {
    type: 'unique',
    only_on_same_position: true
  }
  WORD_SPLIT_FILTER = {
    type: 'word_delimiter',
    preserve_original: 1
  }

  ORIGINAL_FIELD = {
    value: -> { self },
    index: :analyzed,
    analyzer: :original_analyzer
  }
  EDGE_FIELD = {
    value: -> { self },
    index: :analyzed,
    analyzer: :edge_analyzer,
    search_analyzer: :search_analyzer
  }
  NGRAM_FIELD = {
    value: -> { self },
    index: :analyzed,
    analyzer: :ngram_analyzer,
    search_analyzer: :search_analyzer
  }

  DEFAULT_SETTINGS = {
    analysis: {
      analyzer: {
        original_analyzer: ORIGINAL_ANALYZER,
        edge_analyzer: EDGE_ANALYZER,
        ngram_analyzer: NGRAM_ANALYZER,
        search_analyzer: SEARCH_ANALYZER
      },
      tokenizer: {
        edge_ngram_tokenizer: EDGE_NGRAM_TOKENIZER
      },
      filter: {
        edgeNGram_filter: EDGE_NGRAM_FILTER,
        nGram_filter: NGRAM_FILTER,
        distinct_words_filter: DISTINCT_WORDS_FILTER
      }
    }
  }
end
