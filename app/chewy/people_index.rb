class PeopleIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name japanese russian
  ]

  settings DEFAULT_SETTINGS

  define_type Person do
    NAME_FIELDS.each do |name_field|
      field name_field, type: 'keyword', index: false do
        field :original, ORIGINAL_FIELD
        field :edge_phrase, EDGE_PHRASE_FIELD
        field :edge_word, EDGE_WORD_FIELD
        field :ngram, NGRAM_FIELD
      end
    end
    field :is_seyu, type: :boolean, value: -> { seyu? }
    field :is_producer, type: :boolean, value: -> { producer? }
    field :is_mangaka, type: :boolean, value: -> { mangaka? }
  end
end
