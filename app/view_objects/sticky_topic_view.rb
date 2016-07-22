# frozen_string_literal: true

class StickyTopicView
  extend Translation
  include Virtus.model

  # TODO: en topics ids
  TOPIC_IDS = {
    site_rules: { ru: 79_042, en: 220_000 },
    faq: { ru: 85_018, en: 85_018 },
    description_of_genres: { ru: 103_553, en: 103_553 },
    ideas_and_suggestions: { ru: 10_586, en: 10_586 },
    site_problems: { ru: 102, en: 102 }
  }

  attribute :url, String
  attribute :title, String
  attribute :description, String

  %i(
    site_rules
    faq
    description_of_genres
    ideas_and_suggestions
    site_problems
  ).each do |topic_name|
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

  def self.url method_name, locale
    topic_id = TOPIC_IDS[method_name][locale.to_sym]
    Rails.cache.fetch("sticky_topic_url_#{topic_id}") do
      UrlGenerator.instance.topic_url Topic.find(topic_id)
    end
  end

  def self.title method_name, locale
    i18n_t "#{method_name}.title", locale: locale
  end

  def self.description method_name, locale
    i18n_t "#{method_name}.description", locale: locale
  end
end
