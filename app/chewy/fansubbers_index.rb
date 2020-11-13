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

    LETTERS_MIN = 1.0
    LETTERS_MAX = 20.0

    SCORE_MIN = 1.0
    SCORE_MAX = 1.025

    field :weight,
      type: 'half_float',
      index: false,
      # https://www.wolframalpha.com/input/?i=plot+%281.1+%2F+%281+%2B+%281.1+-+1%29+*+%28min%281%2C+max%28%28%28x+-+1.0%29+%2F+%2820.0+-+1.0%29%29%2C+0%29%29%29%29%29+from+x%3D0+to+30
      value: -> (entry, _) {
        x = entry[:id].length

        percent = (x - LETTERS_MIN) / (LETTERS_MAX - LETTERS_MIN)
        fixed_percent = [1, [percent, 0].max].min
        1.0 / (SCORE_MIN + (SCORE_MAX - SCORE_MIN) * percent)
      }
  end
end
