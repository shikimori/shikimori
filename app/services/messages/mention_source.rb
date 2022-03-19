class Messages::MentionSource
  include Translation

  method_object :linked, %i[comment_id is_simple]
  delegate :mention_url, to: :class

  def self.mention_url linked
    case linked
      when NilClass then nil
      when Comment then UrlGenerator.instance.comment_url linked
      when Topic, ClubPage then UrlGenerator.instance.topic_url linked
      when User then UrlGenerator.instance.profile_url linked
      else raise ArgumentError, "#{linked.class} #{linked.to_param}"
    end
  end

  def call
    i18n_t(
      i18n_key,
      name: ERB::Util.h(linked_name),
      url: "#{mention_url @linked}#{comment_hash}",
      bubble: link_bubble
    ).html_safe
  end

private

  def i18n_key
    "#{i18n_primary_key}_mention.#{i18n_secondary_key}"
  end

  def i18n_primary_key
    is_simple ? :simple : :text
  end

  def i18n_secondary_key
    case @linked
      when NilClass then :nil
      when Topic then :topic
      when User then :profile
      else raise ArgumentError, "#{@linked.class} #{@linked.to_param}"
    end
  end

  def linked_name
    case @linked
      when Topic
        @linked.respond_to?(:full_title) ?
          @linked.full_title :
          @linked.title

      when User
        linked.nickname
    end
  end

  def linked_url
  end

  def comment_hash
    "#comment-#{@comment_id}" if @comment_id
  end

  def link_bubble
    url =
      if @comment_id
        UrlGenerator.instance.tooltip_comment_url @comment_id
      elsif linked.is_a? Topic
        "#{mention_url @linked}/tooltip"
      end

    " class=\"bubbled b-link\" data-href=\"#{url}\"" if url
  end
end
