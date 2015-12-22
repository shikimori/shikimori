module Routing
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    def default_url_options
      host = if Rails.env.test?
        'test.host'
      else
        if (Draper::ViewContext.current.request.try(:host) || 'test.host') == 'test.host'
          Site::DOMAIN
        else
          Draper::ViewContext.current.request.host
        end
      end

      { host: host }
    end
  end

  def topic_url topic, format = nil
    if topic.kind_of?(User)
      profile_url topic, subdomain: false

    elsif topic.kind_of?(ContestComment) || (topic.news? && topic.action != 'episode') || topic.review?
      forum_topic_url(
        id: topic,
        forum: topic.forum,
        linked: nil,
        format: format,
        subdomain: false
      )

    else
      forum_topic_url(
        id: topic,
        forum: topic.forum,
        linked_type: topic.linked.class.name.downcase,
        linked_id: topic.linked.to_param,
        format: format,
        subdomain: false
      )
    end
  end

  def forum_url forum, linked = nil
    if linked
      forum_topics_url forum,
        linked_id: linked.to_param,
        linked_type: linked.class.name.downcase
    else
      forum_topics_url forum
    end
  end
end
