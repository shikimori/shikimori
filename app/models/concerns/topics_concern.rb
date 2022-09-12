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

  def generate_topic forum_id: nil
    if self.class < DbEntry
      generate_entry_topics forum_id
    else
      generate_user_topics forum_id
    end
  end

  def topic
    topics.first if topics.any?
  end

  def maybe_topic
    topic || NoTopic.new(linked: self)
  end

private

  def generate_entry_topics forum_id
    Topics::Generate::EntryTopic.call(
      model: self,
      user: topic_user,
      forum_id: forum_id
    )
  end

  def generate_user_topics forum_id
    Topics::Generate::Topic.call(
      model: self,
      user: topic_user,
      forum_id: forum_id
    )
  end
end
