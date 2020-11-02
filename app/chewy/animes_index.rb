class AnimesIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name russian english japanese
    synonyms_0 synonyms_1 synonyms_2 synonyms_3 synonyms_4 synonyms_5
    license_name_ru
  ]

  settings DEFAULT_SETTINGS

  # define_type Anime.where(id: [20, 1735]) do
  # define_type Anime.where("name ilike '%naruto%'") do
  define_type Anime do
    NAME_FIELDS.each do |name_field|
      field(
        name_field,
        type: 'keyword',
        index: false,
        value: lambda do |model|
          if name_field =~ /^(?<name>\w+)_(?<index>\d)$/
            model.send($LAST_MATCH_INFO[:name])[$LAST_MATCH_INFO[:index].to_i]
          else
            model.send(name_field)
          end
        end
      ) do
        field :original, ORIGINAL_FIELD
        field :edge_phrase, EDGE_PHRASE_FIELD
        field :edge_word, EDGE_WORD_FIELD
        field :ngram, NGRAM_FIELD
      end
    end
    field :weight,
      type: 'half_float',
      index: false,
      value: -> (model, _) { 1.2 }#EntryWeight.call model }
  end
end
