class Topics::View < ViewObjectBase # rubocop:disable ClassLength
  vattr_initialize :topic, :is_preview, :is_mini

  delegate :id,
    :user_id,
    :persisted?,
    :user,
    :body,
    :viewed?,
    :generated?,
    :decomposed_body,
    :tags,
    :created_at,
    :updated_at,
    to: :topic

  delegate :comments_count,
    :summaries_count,
    :any_comments?,
    :any_summaries?,
    to: :topic_comments_policy

  delegate :format_date, to: :class

  instance_cache :html_body, :html_body_truncated, :html_footer,
    :comments_view, :urls, :action_tag, :topic_ignore,
    :topic_comments_policy, :topic_type_policy

  BODY_TRUCATE_SIZE = 500
  TRUNCATE_OMNISSION = '…'
  CACHE_VERSION = :v22

  def url options = {}
    UrlGenerator.instance.topic_url @topic, nil, options
  end

  def canonical_url
  end

  def ignored_topic?
    h.user_signed_in? && h.current_user.ignored_topics.include?(@topic)
  end

  def ignored_user?
    h.user_signed_in? && h.current_user.ignores?(@topic.user)
  end

  def preview?
    @is_preview
  end

  def minified?
    @is_mini
  end

  def closed?
    @topic.is_closed
  end

  def pinned?
    @topic.is_pinned
  end

  def prebody?
    false
  end

  def skip_body?
    false
  end

  def container_classes additional = []
    (
      [
        'b-topic',
        ('b-topic-preview' if preview?),
        ('b-topic-minified' if minified?)
      ] + Array(additional)
    ).compact
  end

  def action_tag
  end

  def show_inner?
    preview? || !@topic.generated?
  end

  def footer_vote?
    !preview? && !minified? && topic_type_policy.votable_topic?
  end

  def poster_title
    if preview?
      topic_title
    else
      @topic.user.nickname
    end
  end

  def poster_title_html
    if preview?
      topic_title_html
    else
      @topic.user.nickname
    end
  end

  def topic_title
    if topic_type_policy.forum_topic? || @topic.linked_id.nil?
      @topic.title
    else
      @topic.linked.name
    end
  end

  def topic_title_html
    if topic_type_policy.forum_topic? || @topic.linked_id.nil?
      @topic.title
    else
      h.localization_span @topic.linked
    end
  end

  def render_body
    preview? ? html_body_truncated : html_body
  end

  def poster is_2x
    # last condition is for user topics about anime
    if linked_in_avatar?
      linked =
        if topic_type_policy.critique_topic?
          @topic.linked.target
        elsif topic_type_policy.club_page_topic?
          @topic.linked.club
        else
          @topic.linked
        end

      ImageUrlGenerator.instance.url linked, is_2x ? :x96 : :x48
    else
      @topic.user.avatar_url is_2x ? 80 : 48
    end
  end

  def comments_view
    Topics::CommentsView.new @topic, preview?
  end

  def urls
    Topics::Urls.new self
  end

  def faye_channel
    ["topic-#{@topic.id}"]
  end

  def author_in_header?
    true
  end

  def html_body text = body
    return '' if text.blank?

    Rails.cache.fetch body_cache_key(text) do
      if preview? || minified?
        text = text
          .gsub(%r{\[/?center\]}, '')
          .gsub(%r{\[poster.*?\].*?\[/poster\]|\[poster=.*?\]}, '')
          .strip
      end

      BbCodes::Text.call text, object: @topic
    end
  end

  def html_body_truncated
    h
      .truncate_html(
        html_body,
        length: self.class::BODY_TRUCATE_SIZE,
        separator: ' ',
        word_boundary: /\S[.?!<>]/,
        omission: TRUNCATE_OMNISSION
      )
      .gsub(/(?:<br>)+((?:<[^>]+>)*)\Z/, '\1') # cleanup edge BRs
      .html_safe
  end

  def need_trucation?
    (preview? || minified?) && html_body.size > BODY_TRUCATE_SIZE
  end

  def read_more_link?
    need_trucation? && html_body_truncated != html_body
  end

  def html_footer
    BbCodes::Text.call @topic.decomposed_body.wall
  end

  # для совместимости с комментариями для рендера тултипа
  def offtopic?
    false
  end

  def topic_ignore
    h.user_signed_in? &&
      h.current_user.topic_ignores.find { |v| v.topic_id == @topic.id }
  end

  def topic_ignored?
    topic_ignore.present?
  end

  def status_line?
    true
  end

  def show_source?
    false
  end

  def moderatable?
    !user.bot?
  end

  def topic_type_policy
    Topic::TypePolicy.new @topic
  end

  def cache_key
    CacheHelper.keys(
      self.class.name,
      @topic,
      @topic.respond_to?(:commented_at) ? @topic.commented_at : nil,
      @topic.linked,
      comments_view.comments_limit,
      # не заменять на preview? и minified?,
      # т.к. эти методы могут быть переопределены в наследниках
      @is_preview,
      @is_mini,
      skip_body?,
      closed?, # not sure whether it is necessary
      h.current_user&.preferences&.is_shiki_editor?,
      CACHE_VERSION
    )
  end

  def body_cache_key text
    CacheHelper.keys(
      :body,
      XXhash.xxh32(text),
      preview? || minified?,
      CACHE_VERSION
    )
  end

  def self.format_date datetime
    I18n.l datetime, format: '%e %B %Y'
  end

private

  def body
    @topic.decomposed_body.text
  end

  def linked_in_avatar?
    @topic.linked && preview? &&
      !topic_type_policy.forum_topic?
  end

  def topic_comments_policy
    Topic::CommentsPolicy.new @topic
  end
end
