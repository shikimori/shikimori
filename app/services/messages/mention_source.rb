class Messages::MentionSource < ServiceObjectBase
  include Translation

  pattr_initialize :linked, :comment_id
  instance_cache :url, :text

  def call
    i18n_t(
      "texts.#{i18n_key}",
      name: ERB::Util.h(linked_name),
      url: "#{linked_url}#{comment_hash}",
      bubble: link_bubble
    ).html_safe # rubocop:disable OutputSafety
  end

private

  def i18n_key
    case linked
      when NilClass then :nil
      when Topic then :topic
      when User then :profile
      else raise ArgumentError, "#{linked.class} #{linked.to_param}"
    end
  end

  def linked_name
    case linked
      when Topic
        linked.respond_to?(:full_title) ? linked.full_title : linked.title

      when User
        linked.nickname
    end
  end

  def linked_url
    case linked
      when NilClass then nil
      when Topic then UrlGenerator.instance.topic_url linked
      when User then UrlGenerator.instance.profile_url linked
      when ClubPage then UrlGenerator.instance.topic_url linked
    end
  end

  def comment_hash
    "#comment-#{comment_id}" if comment_id
  end

  def link_bubble
    return unless comment_id

    " class=\"bubbled b-link\" \
data-href=\"#{UrlGenerator.instance.comment_url id: comment_id}\""
  end
end
