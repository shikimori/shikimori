# frozen_string_literal: true

class StickyTopicView
  extend Translation
  include Virtus.model

  TOPIC_IDS = {
    site_rules: { ru: 79_042, en: 220_000 },
    faq: { ru: 85_018, en: nil },
    description_of_genres: { ru: 103_553, en: nil },
    ideas_and_suggestions: { ru: 10_586, en: 230_000 },
    site_problems: { ru: 102, en: 240_000 }
  }

  attribute :url, String
  attribute :title, String
  attribute :description, String

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
      UrlGenerator.instance.topic_url Topic.find(topic_id)
    end
  end

  def self.title topic_name, locale
    i18n_t "#{topic_name}.title", locale: locale
  end

  def self.description topic_name, locale
    i18n_t "#{topic_name}.description", locale: locale
  end
end
