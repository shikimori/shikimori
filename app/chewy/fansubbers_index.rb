class FansubbersIndex < ApplicationIndex
  settings DEFAULT_SETTINGS

  NAME_FIELDS = %i[name]

  define_type(
    -> {
      fansubbers = Anime
        .where.not(fansubbers: [])
        .distinct
        .pluck(Arel.sql('unnest(fansubbers)'))
        .map { |entry| { id: entry, kind: 'fansubbers' } }

      fandubbers = Anime
        .where.not(fandubbers: [])
        .distinct
        .pluck(Arel.sql('unnest(fandubbers)'))
        .map { |entry| { id: entry, kind: 'fandubbers' } }

      fansubbers + fandubbers
    },
    name: 'fansubber'
  ) do
    field :kind,
      type: :keyword,
      value: ->(entry) { entry[:kind] }

    field(
      :name,
      type: :keyword,
      value: ->(entry) { entry[:id] },
      index: false
    ) do
      field :original, ORIGINAL_FIELD
      field :edge_phrase, EDGE_PHRASE_FIELD
      field :edge_word, EDGE_WORD_FIELD
      field :ngram, NGRAM_FIELD
    end
  end
end
