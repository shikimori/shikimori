# https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-analyze.html
# see how analyzer split phrase into tokens
=begin
curl -XPOST 'http://localhost:9200/shikimori_test_clubs/_analyze' \
  -H 'Content-Type: application/json' \
  -d'{ "analyzer": "ngram_analyzer", "text": "kaichou wa" }' | jq

curl -XPOST 'http://localhost:9200/shikimori_test_clubs/_analyze' \
  -H 'Content-Type: application/json' \
  -d'{ "analyzer": "original_analyzer", "text": "kaichou wa" }' | jq
=end

# see how field value is splitted into tokens
=begin
curl -XPOST 'http://localhost:9200/shikimori_test_clubs/_analyze' \
  -H 'Content-Type: application/json' \
  -d'{ "field": "name.synonym", "text": "kaichou wa" }' | jq
=end
class ApplicationIndex < Chewy::Index
  ORIGINAL_FIELD = {
    type: 'text',
    index: true,
    analyzer: :original_analyzer,
    search_analyzer: :search_phrase_analyzer
  }
  EDGE_PHRASE_FIELD = {
    type: 'text',
    index: true,
    analyzer: :edge_phrase_analyzer,
    search_analyzer: :search_phrase_analyzer
  }
  EDGE_WORD_FIELD = {
    type: 'text',
    index: true,
    analyzer: :edge_word_analyzer,
    search_analyzer: :search_word_analyzer
  }
  NGRAM_FIELD = {
    type: 'text',
    index: true,
    analyzer: :ngram_analyzer,
    search_analyzer: :search_word_analyzer
  }

  DEFAULT_SETTINGS = {
    analysis: {
      analyzer: {
        original_analyzer: {
          type: 'custom',
          tokenizer: 'keyword',
          filter: %w[lowercase asciifolding synonyms_filter]
        },
        edge_phrase_analyzer: {
          type: 'custom',
          tokenizer: 'edge_ngram_tokenizer',
          filter: %w[lowercase asciifolding synonyms_filter edgeNGram_filter unique_words_filter]
        },
        edge_word_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[lowercase asciifolding synonyms_filter edgeNGram_filter]
        },
        ngram_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[lowercase asciifolding synonyms_filter nGram_filter distinct_words_filter]
        },
        search_phrase_analyzer: {
          type: 'custom',
          tokenizer: 'keyword',
          filter: %w[lowercase asciifolding synonyms_filter]
        },
        search_word_analyzer: {
          type: 'custom',
          tokenizer: 'standard',
          filter: %w[lowercase asciifolding synonyms_filter]
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
        },
        synonyms_filter: {
          type: 'synonym',
          synonyms: [
            'i, s1, 1',
            'ii, s2, 2, Ⅱ',
            'iii, s3, 3, Ⅲ',
            'iv, s4, 4, Ⅳ',
            'v, s5, 5, Ⅴ',
            'vi, s6, 6, Ⅵ',
            'vii, s7, 7, Ⅶ',
            'viii, s8, 8, Ⅷ',
            'ix, s9, 9, Ⅸ',
            'x, s10, 10, Ⅹ'
          ]
        }
      }
    }
  }
end
