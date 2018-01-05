class CharactersIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name japanese fullname russian
  ]

  settings DEFAULT_SETTINGS

  define_type Character do
    NAME_FIELDS.each do |name_field|
      field name_field, type: :keyword, index: :not_analyzed do
        field :original, ORIGINAL_FIELD
        field :edge, EDGE_FIELD
        field :ngram, NGRAM_FIELD
      end
    end
  end
end
