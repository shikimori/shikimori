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

    elsif topic.kind_of?(ContestComment) || topic.news? || topic.review?
      section_topic_url id: topic, section: topic.section, linked: nil, format: format, subdomain: false

    else
      section_topic_url id: topic, section: topic.section, linked: topic.linked, format: format, subdomain: false
    end
  end
end
