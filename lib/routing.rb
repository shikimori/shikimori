module Routing
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  SHIKIMORI_DOMAIN = %r/
    \A
    (?: (?:play|#{Shikimori::STATIC_SUBDOMAINS.join '|'})\. )
    shikimori \. (?: org|dev )
    \Z
  /mix

  included do
    def shiki_domain
      if Rails.env.test?
        'test.host'
      elsif (Draper::ViewContext.current.request.try(:host) || 'test.host') == 'test.host'
        Shikimori::DOMAIN
      else
        Draper::ViewContext.current.request.host
      end
    end

    def default_url_options
      ApplicationController.default_url_options.merge(host: shiki_domain)
    end
  end

  def topic_url topic, format = nil, options = {}
    topic_type_policy = Topic::TypePolicy.new topic

    if topic.instance_of? NoTopic
      db_entry_url topic.linked, options

    elsif topic.is_a?(User)
      profile_url topic, options.merge(subdomain: false)

    elsif topic_type_policy.any_club_topic?

      club = if topic_type_policy.club_page_topic?
        topic.linked.club
      else
        topic.linked
      end

      club_club_topic_url options.merge(
        club_id: club.to_param,
        id: topic.to_param,
        format: format,
        subdomain: false
      )

    elsif topic_type_policy.not_generated_news_topic? ||
        topic_type_policy.review_topic?

      forum_topic_url options.merge(
        id: topic,
        forum: topic.forum,
        linked: nil,
        format: format,
        subdomain: false
      )

    else
      forum_topic_url options.merge(
        id: topic,
        forum: topic.forum,
        linked_type: topic.linked.class.name.underscore,
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
        linked_type: linked.class.name.underscore
    else
      forum_topics_url forum
    end
  end

  def camo_url image_url
    return image_url if image_url.starts_with? '//', 'https://'
    return image_url if image_url.ends_with? 'eot', 'svg', 'ttf', 'woff', 'woff2'

    url = Url.new(image_url)
    return url.without_protocol.to_s if url.domain.to_s.match? SHIKIMORI_DOMAIN

    @camo_urls ||= {}

    port = ':5566' if Rails.env.development?
    protocol = Shikimori::PROTOCOL

    @camo_urls[image_url] = "#{protocol}://#{shiki_domain}#{port}/" \
      "camo/#{camo_digest image_url}?url=#{CGI.escape image_url}"
  end

private

  def db_entry_url db_entry, options
    public_send "#{db_entry.class.name.underscore}_url", db_entry, options
  end

  def camo_digest url
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha1'),
      Rails.application.secrets[:camo][:key],
      url
    )
  end
end
