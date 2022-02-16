module Routing
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  NON_CAMO_DOMAINS = /
    \A
    (?:
      (?: (?:#{Shikimori::STATIC_SUBDOMAINS.join '|'})\. )?
      shikimori \. (?: org|one|dev|local|test ) |
      static\d?.wallpapers-anime.com |
      images\d.alphacoders.com |
      \w.radikal.ru
    )
    \Z
  /mix
  # FORCE_CAMO_DOMAIN = /imgur.com/i

  included do
    def shiki_domain
      if Rails.env.test?
        'test.host'
      elsif (Draper::ViewContext.current.request.try(:host) || 'test.host') == 'test.host'
        Shikimori::DOMAIN
      else
        Url.new(Draper::ViewContext.current.request.host).cut_subdomain.to_s
      end
    end

    def shiki_one_domain
      Rails.env.production? ? Shikimori::DOMAIN : shiki_domain
    end

    def shiki_port
      if Rails.env.development? && (Draper::ViewContext.current.request.try(:port) || '80') != '80'
        Draper::ViewContext.current.request.port
      end
    end

    def default_url_options
      {
        **ApplicationController.default_url_options,
        host: shiki_domain,
        port: shiki_port
      }
    end
  end

  def topic_url topic, format = nil, options = {} # rubocop:disable all
    topic_type_policy = Topic::TypePolicy.new topic

    if topic.instance_of? NoTopic
      db_entry_url topic.linked, options

    elsif topic.is_a? User
      profile_url topic, options

    elsif topic_type_policy.any_club_topic?
      club =
        if topic_type_policy.club_page_topic?
          topic.linked.club
        else
          topic.linked
        end

      club_club_topic_url options.merge(
        club_id: club.to_param,
        id: topic.to_param,
        format: format
      )

    elsif topic_type_policy.not_generated_news_topic?
      forum_topic_url options.merge(
        id: topic,
        forum: topic.forum,
        linked: nil,
        format: format
      )

    elsif topic_type_policy.critique_topic?
      critique_url topic.linked

    elsif topic_type_policy.review_topic?
      review_url topic.linked

    else
      forum_topic_url options.merge(
        id: topic,
        forum: topic.forum,
        linked_type: topic.linked.class.name.underscore,
        linked_id: topic.linked.to_param,
        format: format
      )
    end
  end

  def critique_url critique, prefix: nil
    send(
      "#{prefix}#{critique.db_entry_type.downcase}_critique_url",
      critique.target,
      critique
    )
  end

  def edit_critique_url critique
    critique_url critique, prefix: 'edit_'
  end

  # def reply_critique_url critique
  #   critique_url critique, is_reply: true
  # end

  def review_url review, prefix: nil
    send(
      "#{prefix}#{review.db_entry_type.downcase}_review_url",
      review.db_entry,
      review
    )
  end

  def edit_review_url review
    review_url review, prefix: 'edit_'
  end

  # def reply_review_url review
  #   review_url review, is_reply: true
  # end

  def forum_url forum, linked = nil
    if linked
      forum_topics_url forum,
        linked_id: linked.to_param,
        linked_type: linked.class.name.underscore
    else
      forum_topics_url forum
    end
  end

  def camo_root_url is_force_shikimori_one
    camo_host = Rails.application.secrets[:camo][:host]
      .gsub('%DOMAIN%', is_force_shikimori_one ? shiki_one_domain : shiki_domain)

    "#{Shikimori::PROTOCOL}://#{camo_host}" +
      Rails.application.secrets[:camo][:endpoint_path]
  end

  def camo_url image_url, force_shikimori_one: true
    @camo_urls ||= {}
    @camo_urls[force_shikimori_one] ||= {}
    @camo_urls[force_shikimori_one][image_url] = generate_camo_url(
      image_url,
      force_shikimori_one
    )
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

  def generate_camo_url image_url, force_shikimori_one
    # NOTE: Do not allow direct urls to https cause it exposes user ip addresses
    # if (
    #     image_url.starts_with?('//', 'https://') ||
    #     image_url.ends_with?('eot', 'svg', 'ttf', 'woff', 'woff2')
    #   ) && !image_url.match?(FORCE_CAMO_DOMAIN)
    #   return image_url
    # end

    if image_url.match?(/\.(?:eot|svg|ttf|woff|woff2|css)(?:$|\?)/)
      return image_url
    end

    url = Url.new(image_url)
    return url.without_protocol.to_s if url.domain.to_s.match? NON_CAMO_DOMAINS

    fixed_url = image_url.starts_with?('//') ? url.with_protocol.to_s : image_url

    camo_root_url(force_shikimori_one) +
      "#{camo_digest fixed_url}?url=#{CGI.escape fixed_url}"
  end
end
