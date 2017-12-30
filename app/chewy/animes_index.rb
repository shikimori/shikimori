class AnimesIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name russian english japanese
    synonym_0 synonym_1 synonym_2 synonym_3 synonym_4 synonym_5
  ]

  DEFAULT_OLD_SCORE = 5
  DEFAULT_NEW_SCORE = 7.5

  KIND_WEIGHT = {
    tv: 10,
    movie: 10,
    ova: 9,
    ona: 9,
    special: 8,
    music: 7,
    other: 6
  }

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
    field :weight,
      type: :half_float,
      index: false,
      value: lambda {
        score_value =
          if score && score < 9.9 && score.positive?
            score
          elsif year && year < 1992
            DEFAULT_OLD_SCORE
          else
            DEFAULT_NEW_SCORE
          end

        kind_value = KIND_WEIGHT[kind&.to_sym] || KIND_WEIGHT[:other]


        (1 + Math.log10(score_value) * Math.log10(kind_value)).round(3)
      }
  end
end
