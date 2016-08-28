# rubocop:disable ClassLength
class Topics::View < ViewObjectBase
  vattr_initialize :topic, :is_preview, :is_mini

  delegate :id, :persisted?, :user, :created_at, :updated_at, :body, :viewed?,
    :comments_count, :summaries_count, :any_comments?, :any_summaries?,
    to: :topic

  instance_cache :comments_view, :urls, :action_tag, :topic_ignore

  def ignored?
    h.user_signed_in? && h.current_user.ignores?(topic.user)
  end

  def minified?
    is_mini
  end

  def container_class css = ''
    [
      css,
      ('b-topic-preview' if is_preview),
      (:mini if is_mini)
    ].compact.join ' '
  end

  def action_tag
  end

  def show_actions?
    h.user_signed_in? && !is_mini
  end

  def show_body?
    is_preview || !topic.generated? || topic.contest?
  end

  def poster_title
    if !is_preview
      topic.user.nickname
    else
      topic_title
    end
  end

  def topic_title
    if topic.topic? || topic.linked_id.nil?
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
      linked = topic.review? ? topic.linked.target : topic.linked
      ImageUrlGenerator.instance.url linked, is_2x ? :x96 : :x48
    else
      topic.user.avatar_url is_2x ? 80 : 48
    end
  end

  def comments_view
    Topics::CommentsView.new topic, is_preview
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
    (is_preview || is_mini) && topic.review?
  end

  # def author_in_footer?
    # is_preview && (topic.news? || topic.review?) &&
      # (!author_in_header? || poster(false) != user.avatar_url(48))
  # end

  def html_body
    Rails.cache.fetch body_cache_key, expires_in: 2.weeks do
      BbCodeFormatter.instance.format_comment topic_body
    end
  end

  # # надо ли свёртывать длинный контент топика?
  # def should_shorten?
    # !news? || (news? && generated?) || (news? && object.body !~ /\[wall\]/)
  # end

  # # тег топика
  # def tag
    # return nil if linked.nil? || review? || contest?

    # if linked.kind_of? Review
      # h.localized_name linked.target
    # else
      # if linked.respond_to?(:name) && linked.respond_to?(:russian)
        # h.localized_name linked
      # end
    # end
  # end

  def html_body_truncated
    if is_preview
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

private

  def body_cache_key
    [topic, topic.linked, 'body']
  end

  def topic_body
    topic.original_body
  end

  def linked_in_avatar?
    topic.linked && is_preview && !topic.instance_of?(Topic)
  end

  def cleanup_preview_body html
    html
      .gsub(%r{<a [^>]* class="b-image.*?</a>}, '')
      .gsub(%r{<center></center>}, '')
      .gsub(/\A(<br>)+/, '')
  end
end
# rubocop:enable ClassLength
