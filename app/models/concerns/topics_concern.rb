module TopicsConcern
  extend ActiveSupport::Concern

  included do
    # special association for dependent destroy
    has_many :all_topics,
      class_name: 'Topic',
      as: :linked,
      dependent: :destroy

    has_many :topics, -> { order updated_at: :desc },
      class_name: "Topics::EntryTopics::#{name}Topic",
      as: :linked,
      inverse_of: :linked # topic always load know its linked

    has_many :news_topics, -> { order created_at: :desc },
      class_name: 'Topics::NewsTopic',
      as: :linked,
      inverse_of: :linked # topic always must know its linked

    attr_implement :topic_user
  end

  def generate_topics locales, forum_id: nil
    if self.class < DbEntry
      generate_entry_topics locales, forum_id
    else
      generate_user_topics locales, forum_id
    end
  end

  # useng find with block converts topics to array and
  # doesn't query database since relation is preloaded
  def topic locale
    topics.find { |topic| topic.locale == locale }
  end

  def maybe_topic locale
    topic(locale) || NoTopic.new(linked: self)
  end

private

  def generate_entry_topics locales, forum_id
    Array(locales).map do |locale|
      Topics::Generate::EntryTopic.call(
        model: self,
        user: topic_user,
        locale: locale,
        forum_id: forum_id
      )
    end
  end

  def generate_user_topics locales, forum_id
    Array(locales).map do |locale|
      Topics::Generate::Topic.call(
        model: self,
        user: topic_user,
        locale: locale,
        forum_id: forum_id
      )
    end
  end
end
