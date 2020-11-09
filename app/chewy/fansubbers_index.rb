class FansubbersIndex < ApplicationIndex
  settings DEFAULT_SETTINGS

  NAME_FIELDS = %i[name]

  define_type(
    -> {
      fansubbers = Anime
        .where.not(fansubbers: [])
        .distinct
        .pluck(Arel.sql('unnest(fansubbers)'))
        .map { |entry| { id: entry, kind: Types::Fansubber::Kind[:fansubber] } }

      fandubbers = Anime
        .where.not(fandubbers: [])
        .distinct
        .pluck(Arel.sql('unnest(fandubbers)'))
        .map { |entry| { id: entry, kind: Types::Fansubber::Kind[:fandubber] } }

      fansubbers + fandubbers
    },
    name: 'fansubber'
  ) do
    field :kind,
      type: 'keyword',
      value: ->(entry) { entry[:kind] }

    field :name,
      type: 'keyword',
      index: false,
      value: ->(entry) { entry[:id] },
      fields: {
        original: ORIGINAL_FIELD,
        edge_phrase: EDGE_PHRASE_FIELD,
        edge_word: EDGE_WORD_FIELD,
        ngram: NGRAM_FIELD
      }
  end
end
