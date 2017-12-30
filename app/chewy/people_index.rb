class PeopleIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name japanese russian
  ]

  settings DEFAULT_SETTINGS

  define_type Person do
    NAME_FIELDS.each do |name_field|
      field name_field, type: :keyword, index: :not_analyzed do
        field :original, ORIGINAL_FIELD
        field :edge, EDGE_FIELD
        field :ngram, NGRAM_FIELD
      end
    end
    field :seyu, type: :boolean
    field :producer, type: :boolean
    field :mangaka, type: :boolean
  end
end
