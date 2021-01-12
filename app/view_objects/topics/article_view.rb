class Topics::ArticleView < Topics::UserContentView
  BODY_TRUCATE_SIZE = 125

  def container_classes
    super 'b-article-topic'
  end

  def need_trucation?
    preview? || minified?
  end

  def action_tag
    OpenStruct.new(
      type: 'article',
      text: i18n_i('article', :one)
    )
  end

  def url options = {}
    if is_mini
      canonical_url
    else
      super
    end
  end

  def canonical_url
    h.article_url article
  end

  def skip_body?
    preview? && html_footer.present?
  end

  def linked_in_avatar?
    false
  end

private

  def article
    @topic.linked
  end
end
