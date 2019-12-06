# frozen_string_literal: true

# views for topics to be shown in sticky topics forum section:
# all of them belong to offtopic forum
class StickyClubView
  include ShallowAttributes
  extend Translation

  attribute :object, Object
  attribute :title, String
  attribute :description, String

  CLUB_IDS = {
    faq: { ru: 1_093, en: nil },
    content_moderation: { ru: 2052, en: nil },
    forum_moderation: { ru: 917, en: nil }
  }

  CLUB_IDS.keys.each do |club_name|
    define_singleton_method club_name do |locale|
      club_id = CLUB_IDS[club_name][locale.to_sym]
      next unless club_id.present?

      instance_variable_get(:"@#{club_name}_#{locale}") ||
        instance_variable_set(
          :"@#{club_name}_#{locale}",
          new(
            object: clubs[club_id],
            title: club_name(club_id),
            description: description(club_name, locale)
          )
        )
    end
  end

  def self.club_name club_id
    clubs[club_id].name
  end

  def self.description club_name, locale
    i18n_t "#{club_name}.description", locale: locale
  end

  def self.clubs
    @clubs ||= Hash.new do |cache, club_id|
      cache[club_id] = Club.find(club_id).decorate
    end
  end
end
