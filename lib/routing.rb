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
      section_topic_url(
        id: topic,
        section: topic.section,
        linked: nil,
        format: format,
        subdomain: false
      )

    else
      section_topic_url(
        id: topic,
        section: topic.section,
        linked_type: topic.linked.class.name.downcase,
        linked_id: topic.linked.to_param,
        format: format,
        subdomain: false
      )
    end
  end

  def section_url section, linked = nil
    if linked
      section_topics_url section,
        linked_id: linked.to_param,
        linked_type: linked.class.name.downcase
    else
      section_topics_url section
    end
  end
end
