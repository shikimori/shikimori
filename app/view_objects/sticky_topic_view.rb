# frozen_string_literal: true

# views for topics to be shown in sticky topics forum section:
# all of them belong to offtopic forum
class StickyTopicView < Dry::Struct
  extend Translation

  attribute :url, Types::Strict::String
  attribute :title, Types::Strict::String
  attribute :description, Types::Strict::String

  STICKY_TOPICS = %i(
    site_rules
    description_of_genres
    ideas_and_suggestions
    site_problems
  )
  STICKY_CLUBS = %i(faq)
  OFFTOPIC_TOPIC_IDS = Topic::TOPIC_IDS[Forum::OFFTOPIC_ID]

  CLUB_IDS = {
    faq: { ru: 1_093, en: nil }
  }

  (STICKY_TOPICS + STICKY_CLUBS).each do |topic_name|
    define_singleton_method topic_name do |locale|
      if OFFTOPIC_TOPIC_IDS[topic_name]
        topic_id = OFFTOPIC_TOPIC_IDS[topic_name][locale.to_sym]
      end

      if CLUB_IDS[topic_name]
        club_id = CLUB_IDS[topic_name][locale.to_sym]
      end

      next unless topic_id || club_id

      instance_variable_get(:"@#{topic_name}_#{locale}") ||
        instance_variable_set(
          :"@#{topic_name}_#{locale}",
          new(
            url: topic_id ? topic_url(topic_id) : club_url(club_id),
            title: topic_id ? topic_title(topic_id) : club_name(club_id),
            description: description(topic_name, locale)
          )
        )
    end
  end

  private_class_method

  def self.topic_url topic_id
    Rails.cache.fetch("sticky_topic_url_#{topic_id}") do
      UrlGenerator.instance.topic_url topics[topic_id]
    end
  end

  def self.club_url club_id
    Rails.cache.fetch("sticky_club_url_#{club_id}") do
      UrlGenerator.instance.club_url clubs[club_id]
    end
  end

  def self.topic_title topic_id
    topics[topic_id].title
  end

  def self.club_name club_id
    clubs[club_id].name
  end

  def self.description topic_name, locale
    i18n_t "#{topic_name}.description", locale: locale
  end

  def self.topics
    @topics ||= Hash.new do |cache, topic_id|
      cache[topic_id] = Topic.find topic_id
    end
  end

  def self.clubs
    @clubs ||= Hash.new do |cache, club_id|
      cache[club_id] = Club.find club_id
    end
  end
end
