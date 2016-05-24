# NOTE: implement `topic_user` method in including classes
module TopicsConcern
  extend ActiveSupport::Concern

  included do
    has_many :topics, -> { order updated_at: :desc },
      class_name: "Topics::EntryTopics::#{self.name}Topic",
      as: :linked,
      dependent: :destroy
  end

  def generate_topics locales
    if self.class < DbEntry
      generate_site_topics locales
    else
      generate_user_topics locales
    end
  end

private

  def generate_site_topics locales
    Array(locales).each do |locale|
      Topics::Generate::SiteTopic.call self, topic_user, locale
    end
  end

  def generate_user_topics locales
    Array(locales).each do |locale|
      Topics::Generate::UserTopic.call self, topic_user, locale
    end
  end
end
