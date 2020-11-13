class UsersIndex < ApplicationIndex
  NAME_FIELDS = %i[nickname]

  settings DEFAULT_SETTINGS

  define_type User do
    field :nickname,
      type: 'keyword',
      index: false,
      fields: {
        original: ORIGINAL_FIELD,
        edge_phrase: EDGE_PHRASE_FIELD,
        edge_word: EDGE_WORD_FIELD,
        ngram: NGRAM_FIELD
      }

    field :weight,
      type: 'half_float',
      index: false,
      # https://www.wolframalpha.com/input/?i=plot+%281.1+%2F+%281+%2B+%281.1+-+1%29+*+%28min%281%2C+max%28%28%28x+-+1.0%29+%2F+%2820.0+-+1.0%29%29%2C+0%29%29%29%29%29+from+x%3D0+to+30
      value: -> (entry, _) { Relevance::LengthWeight.call entry.nickname.length }
  end
end
