class TopicsIndex < ApplicationIndex
  NAME_FIELDS = %i[title russian english english_2]

  settings DEFAULT_SETTINGS

  FIELD_VALUE = {
    title: ->(topic) { Topics::TopicViewFactory.new(true, true).build(topic).topic_title },
    russian: ->(topic) {
      target = topic.linked.respond_to?(:target) ? topic.linked.target : topic.linked
      return unless target

      if target.respond_to? :title_ru
        target.title_ru
      elsif target.respond_to? :russian
        target.russian
      end
    },
    english: ->(topic) {
      target = topic.linked.respond_to?(:target) ? topic.linked.target : topic.linked
      return unless target

      if target.respond_to? :title_en
        target.title_en
      elsif target.respond_to? :english
        target.english
      end
    },
    english_2: ->(topic) {
      target = topic.linked.respond_to?(:target) ? topic.linked.target : topic.linked
      return unless target

      if target.respond_to? :name
        target.name
      end
    }
  }

  define_type Topic.includes(:linked) do
    NAME_FIELDS.each do |name_field|
      field name_field,
        type: 'keyword',
        index: false,
        value: -> {
          if FIELD_VALUE[name_field]
            FIELD_VALUE[name_field].(self)
          else
            send(name_field)
          end
        },
        fields: {
          original: ORIGINAL_FIELD,
          edge_phrase: EDGE_PHRASE_FIELD,
          edge_word: EDGE_WORD_FIELD,
          ngram: NGRAM_FIELD
        }
    end
    field :locale, type: 'keyword'
    field :forum_id, type: :integer
  end
end
