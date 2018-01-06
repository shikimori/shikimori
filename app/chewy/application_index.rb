# https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html
# see how analyzer split phrase to tokens
# curl -XGET 'http://localhost:9200/shikimori_development_clubs/_analyze?analyzer=ngram_analyzer' -d'kaichou wa' | jq
# curl -XGET 'http://localhost:9200/shikimori_development_clubs/_analyze?analyzer=search_analyzer' -d'kaichou wa' | jq

# see how field value is splitted to tokens
# curl -XGET 'http://localhost:9200/shikimori_development_clubs/_analyze?field=name.synonym' -d 'kaichou wa' | jq
class ApplicationIndex < Chewy::Index
  ORIGINAL_ANALYZER = {
    type: 'custom',
    tokenizer: 'keyword',
    filter: %w[lowercase asciifolding]
  }
  EDGE_PHRASE_ANALYZER = {
    type: 'custom',
    tokenizer: 'edge_ngram_tokenizer',
    filter: %w[lowercase asciifolding edgeNGram_filter unique_words_filter]
  }
  EDGE_WORD_ANALYZER = {
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
    max_gram: 99
  }

  EDGE_NGRAM_FILTER = {
    type: 'edgeNGram',
    min_gram: 1,
    max_gram: 99,
    side: 'front'
  }
  NGRAM_FILTER = {
    type: 'nGram',
    min_gram: 1,
    max_gram: 99
  }
  UNIQUE_WORDS_FILTER = {
    type: 'unique'
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
  EDGE_PHRASE_FIELD = {
    value: -> { self },
    index: :analyzed,
    analyzer: :edge_phrase_analyzer,
  }
  EDGE_WORD_FIELD = {
    value: -> { self },
    index: :analyzed,
    analyzer: :edge_word_analyzer,
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
        edge_phrase_analyzer: EDGE_PHRASE_ANALYZER,
        edge_word_analyzer: EDGE_WORD_ANALYZER,
        ngram_analyzer: NGRAM_ANALYZER,
        search_analyzer: SEARCH_ANALYZER
      },
      tokenizer: {
        edge_ngram_tokenizer: EDGE_NGRAM_TOKENIZER
      },
      filter: {
        edgeNGram_filter: EDGE_NGRAM_FILTER,
        nGram_filter: NGRAM_FILTER,
        distinct_words_filter: DISTINCT_WORDS_FILTER,
        unique_words_filter: UNIQUE_WORDS_FILTER
      }
    }
  }
end
