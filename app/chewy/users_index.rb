# посмотреть, на какие токены analyzer побил фразу
# curl -XGET 'http://localhost:9200/shikimori_development_users/_analyze?analyzer=ngram_analyzer' -d'gen_31_2958' | jq
# curl -XGET 'http://localhost:9200/shikimori_development_users/_analyze?analyzer=search_analyzer' -d'gen_31_2958' | jq

# посмотреть, на какие токены будет разбито значение, переданное в поле
# curl -XGET 'localhost:9200/shikimori_development_users/_analyze?field=sku.ngram' -d 'gen_31_2958' | jq
class UsersIndex < Chewy::Index
  NAME_FIELDS = %i[nickname]

  settings analysis: {
    analyzer: {
      original_analyzer: {
        type: 'custom',
        tokenizer: 'keyword',
        filter: %w[lowercase asciifolding]
      },
      edge_analyzer: {
        type: 'custom',
        tokenizer: 'standard',
        filter: %w[lowercase asciifolding edgeNGram_filter]
      },
      ngram_analyzer: {
        type: 'custom',
        tokenizer: 'standard',
        filter: %w[lowercase asciifolding nGram_filter distinct_words]
      },
      search_analyzer: {
        type: 'custom',
        tokenizer: 'standard',
        filter: %w[lowercase asciifolding distinct_words],
      }
    },
    tokenizer: {
      edge_ngram_tokenizer: {
        type: 'edgeNGram',
        min_gram: 1,
        max_gram: 30
      }
    },
    filter: {
      edgeNGram_filter: {
        type: 'edgeNGram',
        min_gram: 1,
        max_gram: 30,
        side: 'front'
      },
      nGram_filter: {
        type: 'nGram',
        min_gram: 1,
        max_gram: 30
      },
      distinct_words: {
        type: 'unique',
        only_on_same_position: true
      },
      word_split: {
        type: 'word_delimiter',
        preserve_original: 1
      }
    }
  }

  define_type User do
    field :nickname, type: :keyword, index: :not_analyzed do
      field :original,
        value: -> { self },
        index: :analyzed,
        analyzer: :original_analyzer
      field :edge,
        value: -> { self },
        index: :analyzed,
        analyzer: :edge_analyzer,
        search_analyzer: :search_analyzer
      field :ngram,
        value: -> { self },
        index: :analyzed,
        analyzer: :ngram_analyzer,
        search_analyzer: :search_analyzer
    end
  end
end
