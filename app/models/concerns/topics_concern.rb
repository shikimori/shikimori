# NOTE: implement these methods in including classes:
#
# - topic_auto_generated? (create after_save callback if yes)
# - topic_user
module TopicsConcern
  extend ActiveSupport::Concern

  included do
    has_many :topics, -> { order updated_at: :desc },
      class_name: "Topics::EntryTopics::#{self.name}Topic",
      as: :linked,
      dependent: :destroy

    after_create :generate_topics, if: :topic_auto_generated?
  end

  def generate_topics
    if self.class < DbEntry
      generate_site_topics
    else
      generate_user_topics
    end
  end

  def locales
    Array(try :locale).presence || I18n.available_locales
  end

private

  def generate_site_topics
    locales.each do |locale|
      Topics::Generate::SiteTopic.call self, topic_user, locale
    end
  end

  def generate_user_topics
    locales.each do |locale|
      Topics::Generate::UserTopic.call self, topic_user, locale
    end
  end
end
