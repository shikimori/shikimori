class LicensorsIndex < ApplicationIndex
  settings DEFAULT_SETTINGS

  NAME_FIELDS = %i[name]

  define_type(
    -> {
      animes = Anime
        .where.not(licensors: [])
        .distinct
        .pluck(Arel.sql('unnest(licensors)'))
        .map { |entry| { id: entry, kind: Types::Licensor::Kind[:anime] } }

      mangas = Manga
        .where.not(licensors: [])
        .distinct
        .pluck(Arel.sql('unnest(licensors)'))
        .map { |entry| { id: entry, kind: Types::Licensor::Kind[:manga] } }

      animes + mangas
    },
    name: 'licensor'
  ) do
    field :kind,
      type: 'keyword',
      value: ->(entry) { entry[:kind] }

    field(
      :name,
      type: 'keyword',
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
