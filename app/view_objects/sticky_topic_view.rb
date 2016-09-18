# frozen_string_literal: true

# views for topics to be shown in sticky topics forum section:
# all of them belong to offtopic forum
class StickyTopicView
  extend Translation
  include Virtus.model

  attribute :url, String
  attribute :title, String
  attribute :description, String

  TOPIC_IDS = Topic::TOPIC_IDS[Forum::OFFTOPIC_ID]

  TOPIC_IDS.keys.each do |topic_name|
    define_singleton_method topic_name do |locale|
      instance_variable_get(:"@#{__method__}_#{locale}") ||
        instance_variable_set(
          :"@#{__method__}_#{locale}",
          new(
            url: url(__method__, locale),
            title: title(__method__, locale),
            description: description(__method__, locale)
          )
        )
    end
  end

private

  def self.url topic_name, locale
    topic_id = TOPIC_IDS[topic_name][locale.to_sym]
    Rails.cache.fetch("sticky_topic_url_#{topic_id}") do
      UrlGenerator.instance.topic_url topics[topic_id]
    end
  end

  def self.title topic_name, locale
    topic_id = TOPIC_IDS[topic_name][locale.to_sym]
    topics[topic_id].title
  end

  def self.description topic_name, locale
    i18n_t "#{topic_name}.description", locale: locale
  end

  def self.topics
    @topics ||= Hash.new do |cache, topic_id|
      cache[topic_id] = Topic.find topic_id
    end
  end
end
