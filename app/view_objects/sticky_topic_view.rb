# frozen_string_literal: true

# views for topics to be shown in sticky topics forum section:
# all of them belong to offtopic forum
class StickyTopicView
  include ShallowAttributes
  extend Translation

  attribute :object, Object
  attribute :title, String
  attribute :description, String

  STICKY_TOPICS = %i[
    site_rules
    description_of_genres
    ideas_and_suggestions
    site_problems
    contests_proposals
  ]
  GLOBAL_TOPICS = %i[
    socials
  ]
  (STICKY_TOPICS + GLOBAL_TOPICS).each do |topic_name|
    define_singleton_method topic_name do
      topic_id = Topic::TOPIC_IDS[topic_name][:ru]
      next unless topic_id.present?

      instance_variable_get(:"@#{topic_name}") ||
        instance_variable_set(
          :"@#{topic_name}",
          new(
            object: Topics::TopicViewFactory.new(true, true).build(topics[topic_id]),
            title: (title(topic_id) if STICKY_TOPICS.include?(topic_name)),
            description: (description(topic_name) if STICKY_TOPICS.include?(topic_name))
          )
        )
    end
  end
  GLOBAL_TOPICS.each do |topic_name|
    define_singleton_method topic_name do
      topic_id = Topic::TOPIC_IDS[topic_name][:ru]
      next unless topic_id.present?

      instance_variable_get(:"@#{topic_name}") ||
        instance_variable_set(
          :"@#{topic_name}",
          new(
            object: Topics::TopicViewFactory.new(true, true).build(topics[topic_id]),
            title: '',
            description: ''
          )
        )
    end
  end

  def self.title topic_id
    topics[topic_id].title
  end

  def self.description topic_name
    i18n_t "#{topic_name}.description"
  end

  def self.topics
    @topics ||= Hash.new do |cache, topic_id|
      cache[topic_id] = Topic.find topic_id
    rescue ActiveRecord::RecordNotFound
      raise if Rails.env.test?

      Topic.new id: topic_id
    end
  end
end
