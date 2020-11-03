class UsersIndex < ApplicationIndex
  NAME_FIELDS = %i[nickname]

  settings DEFAULT_SETTINGS

  define_type User do
    NAME_FIELDS.each do |name_field|
      field name_field, type: 'keyword', index: false do
        field :original, ORIGINAL_FIELD
        field :edge_phrase, EDGE_PHRASE_FIELD
        field :edge_word, EDGE_WORD_FIELD
        field :ngram, NGRAM_FIELD
      end
    end
  end
end
