class RanobeIndex < ApplicationIndex
  NAME_FIELDS = %i[
    name russian english japanese
    synonyms_0 synonyms_1 synonyms_2 synonyms_3 synonyms_4 synonyms_5
  ]

  settings DEFAULT_SETTINGS

  # KIND_WEIGHT = {
  #   novel: 1.2
  # }

  define_type Ranobe do
    NAME_FIELDS.each do |name_field|
      field(
        name_field,
        type: :keyword,
        index: :not_analyzed,
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
    # field :score, type: :half_float, index: false
    # field :year, type: :half_float, index: false
    # field :kind_weight,
    #   type: :half_float,
    #   index: false,
    #   value: -> { KIND_WEIGHT[kind&.to_sym] || 1 }
    field :weight,
      type: :half_float,
      index: false,
      value: -> (model, _) { EntryWeight.call model }
  end
end
