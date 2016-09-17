# rubocop:disable ClassLength
class Topics::View < ViewObjectBase
  vattr_initialize :topic, :is_preview, :is_mini

  delegate :id, :persisted?, :user, :created_at,
    :updated_at, :body, :viewed?, to: :topic

  delegate :comments_count, :summaries_count, to: :topic_comments_policy
  delegate :any_comments?, :any_summaries?, to: :topic_comments_policy

  instance_cache :html_body, :comments_view, :urls, :action_tag, :topic_ignore
  instance_cache :topic_comments_policy, :topic_type_policy

  def ignored_topic?
    h.user_signed_in? && h.current_user.ignored_topics.include?(topic)
  end

  def ignored_user?
    h.user_signed_in? && h.current_user.ignores?(topic.user)
  end

  def preview?
    is_preview
  end

  def minified?
    is_mini
  end

  def container_class css = ''
    [
      css,
      ('b-topic-preview' if preview?),
      (:mini if minified?)
    ].compact.join ' '
  end

  def action_tag
  end

  def show_body?
    preview? ||
      !topic.generated? ||
      topic_type_policy.contest_topic?
  end

  def poster_title
    if !preview?
      topic.user.nickname
    else
      topic_title
    end
  end

  def topic_title
    if topic_type_policy.forum_topic? || topic.linked_id.nil?
      topic.title
    else
      h.localized_name topic.linked
    end
  end

  def render_body
    html_body
  end

  # картинка топика (аватарка автора)
  def poster is_2x
    # последнее условие для пользовательских топиков об аниме
    if linked_in_avatar?
      linked = if topic_type_policy.review_topic?
        topic.linked.target
      else
        topic.linked
      end

      ImageUrlGenerator.instance.url linked, is_2x ? :x96 : :x48
    else
      topic.user.avatar_url is_2x ? 80 : 48
    end
  end

  def comments_view
    Topics::CommentsView.new topic, preview?
  end

  def urls
    Topics::Urls.new self
  end

  def faye_channel
    ["topic-#{topic.id}"].to_json
  end

  def author_in_header?
    true
  end

  def read_more_link?
    (preview? || minified?) && topic_type_policy.review_topic?
  end

  # def author_in_footer?
    # preview? && (topic_type_policy.news_topic? || topic_type_policy.review_topic?) &&
      # (!author_in_header? || poster(false) != user.avatar_url(48))
  # end

  def html_body
    Rails.cache.fetch [:body, Digest::MD5.hexdigest(topic_body)] do
      BbCodeFormatter.instance.format_comment topic_body
    end
  end

  # # надо ли свёртывать длинный контент топика?
  # def should_shorten?
    # !news_topic? || (news_topic? && generated?) || (news_topic? && object.body !~ /\[wall\]/)
  # end

  # # тег топика
  # def tag
    # return nil if linked.nil? || review_topic? || contest_topic?

    # if linked.kind_of? Review
      # h.localized_name linked.target
    # else
      # if linked.respond_to?(:name) && linked.respond_to?(:russian)
        # h.localized_name linked
      # end
    # end
  # end

  def html_body_truncated
    if preview?
      html = h.truncate_html cleanup_preview_body(html_body),
        length: 500,
        separator: ' ',
        word_boundary: /\S[\.\?\!<>]/

      html.html_safe
    else
      html_body
    end
  end

  def html_footer
    BbCodeFormatter.instance.format_comment topic.appended_body
  end

  # для совместимости с комментариями для рендера тултипа
  def offtopic?
    false
  end

  def topic_ignore
    h.user_signed_in? &&
      h.current_user.topic_ignores.find { |v| v.topic_id == topic.id }
  end

  def topic_ignored?
    topic_ignore.present?
  end

  def topic_type_policy
    Topic::TypePolicy.new topic
  end

  def cache_key
    CacheHelper.keys(
      topic.cache_key,
      topic.commented_at,
      comments_view.comments_limit,
      preview?,
      minified?
    )
  end

private

  def topic_body
    topic.original_body
  end

  def linked_in_avatar?
    topic.linked && preview? && !topic.instance_of?(Topic)
  end

  def cleanup_preview_body html
    html
      .gsub(%r{<a [^>]* class="b-image.*?</a>}, '')
      .gsub(%r{<center></center>}, '')
      .gsub(/\A(<br>)+/, '')
  end

  def topic_comments_policy
    Topic::CommentsPolicy.new topic
  end
end
# rubocop:enable ClassLength
