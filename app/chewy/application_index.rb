# https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html
# see how analyzer split phrase to tokens
# curl -XGET 'http://localhost:9200/shikimori_development_clubs/_analyze?analyzer=ngram_analyzer' -d'kaichou wa' | jq
# curl -XGET 'http://localhost:9200/shikimori_development_clubs/_analyze?analyzer=search_analyzer' -d'kaichou wa' | jq

# see how field value is splitted to tokens
# curl -XGET 'http://localhost:9200/shikimori_development_clubs/_analyze?field=name.synonym' -d 'kaichou wa' | jq
class ApplicationIndex < Chewy::Index
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
        original_analyzer: {
          type: 'custom',
          tokenizer: 'keyword',
          filter: %w[lowercase asciifolding]
        },
        edge_phrase_analyzer: {
          type: 'custom',
          tokenizer: 'edge_ngram_tokenizer',
          filter: %w[lowercase asciifolding edgeNGram_filter unique_words_filter]
        },
        edge_word_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[lowercase asciifolding edgeNGram_filter]
        },
        ngram_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[lowercase asciifolding nGram_filter distinct_words_filter]
        },
        search_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[lowercase asciifolding distinct_words_filter]
        }
      },
      tokenizer: {
        edge_ngram_tokenizer: {
          type: 'edgeNGram',
          min_gram: 1,
          max_gram: 99
        }
      },
      filter: {
        edgeNGram_filter: {
          type: 'edgeNGram',
          min_gram: 1,
          max_gram: 99,
          side: 'front'
        },
        nGram_filter: {
          type: 'nGram',
          min_gram: 1,
          max_gram: 99
        },
        distinct_words_filter: {
          type: 'unique',
          only_on_same_position: true
        },
        unique_words_filter: {
          type: 'unique'
        }
      }
    }
  }
end
