class MangasIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name russian english japanese
    synonyms_0 synonyms_1 synonyms_2 synonyms_3 synonyms_4 synonyms_5
  ]

  KIND_WEIGHT = {
    manga: 1.2,
    manhwa: 1.2,
    manhua: 1.2,
    novel: 1.2,
    doujin: 1.1
  }

  settings DEFAULT_SETTINGS

  define_type Manga.where.not(type: Ranobe.name) do
    NAME_FIELDS.each do |name_field|
      field name_field, type: :keyword, index: :not_analyzed do
        field :original, ORIGINAL_FIELD.merge(ARRAY_INDEX_FIELD)
        field :edge, EDGE_FIELD.merge(ARRAY_INDEX_FIELD)
        field :ngram, NGRAM_FIELD.merge(ARRAY_INDEX_FIELD)
      end
    end
    field :score, type: :half_float, index: false
    field :year, type: :half_float, index: false
    field :kind_weight,
      type: :half_float,
      index: false,
      value: -> { KIND_WEIGHT[kind&.to_sym] || 1 }
    field :weight,
      type: :half_float,
      index: false,
      value: -> { ApplicationIndex.weight self }
  end
end
