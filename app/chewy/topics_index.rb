class TopicsIndex < ApplicationIndex
  NAME_FIELDS = %i[title]

  settings DEFAULT_SETTINGS

  define_type Topic do
    NAME_FIELDS.each do |name_field|
      field(name_field,
        type: :keyword,
        index: :not_analyzed,
        value: -> { Topics::TopicViewFactory.new(true, true).build(self).topic_title }
      ) do
        field :original, ORIGINAL_FIELD
        field :edge_phrase, EDGE_PHRASE_FIELD
        field :edge_word, EDGE_WORD_FIELD
        field :ngram, NGRAM_FIELD
      end
    end
    field :locale, type: :keyword
    field :forum_id, type: :integer
  end
end
