class CharactersIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name japanese fullname russian
  ]

  settings analysis: {
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

  define_type Anime do
    NAME_FIELDS.each do |name_field|
      field name_field, type: :keyword, index: :not_analyzed do
        field :original, ORIGINAL_FIELD
        field :edge, EDGE_FIELD
        field :ngram, NGRAM_FIELD
      end
    end
  end
end
