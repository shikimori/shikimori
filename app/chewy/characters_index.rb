class CharactersIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name japanese fullname russian
  ]

  settings JP_SETTINGS

  define_type Character do
    NAME_FIELDS.each do |name_field|
      field name_field,
        type: 'keyword',
        index: false,
        fields: {
          original: ORIGINAL_FIELD,
          edge_phrase: EDGE_PHRASE_FIELD,
          edge_word: EDGE_WORD_FIELD,
          ngram: NGRAM_FIELD
        }
    end
  end
end
