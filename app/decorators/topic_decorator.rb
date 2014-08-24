class TopicDecorator < BaseDecorator
  FOLD_LIMIT = 20
  instance_cache :comments

  # имя топика
  def title
    if !preview?
      user.nickname
    elsif contest?
      object.title
    #elsif @linked # для топиков при указанном linked будет короткое название
      #if @linked.respond_to? :name
        #"#{object.to_s} #{@linked.name}"
      #else
        #object.to_s
      #end
    ##elsif object.respond_to?(:linked) && object.linked # надо подумать, стоит ли топики переименовывать
      ##UserPresenter.localized_name object.linked, current_user
    elsif object.respond_to? :title
      object.title
    else
      object.name
    end
  end

  # текст топика
  def body
    Rails.cache.fetch [object, h.russian_names_key, 'body'], expires_in: 2.weeks do
      BbCodeFormatter.instance.format_comment object.body
    end
  end

  # картинка топика(аватарка автора)
  def avatar
    if object.special? && object.linked.respond_to?(:image) && !(object.news? && !object.generated? && !preview?)
      object.linked.image.url(:x96)
    elsif object.special? && object.linked.respond_to?(:logo)
      object.linked.logo.url(:x48)
    elsif review?
      object.linked.object.image.url(:x96)
    else
      object.user.avatar_url(48)
    end
  end

  def avatar2x
    if object.special? && object.linked.respond_to?(:image) && !(object.news? && !object.generated? && !preview?)
      object.linked.image.url(:x96)
    elsif object.special? && object.linked.respond_to?(:logo)
      object.linked.logo.url(:x96)
    elsif review?
      object.linked.object.image.url(:x96)
    else
      object.user.avatar_url(80)
    end
  end

  # дата создания топика
  def date
    Russian::strftime(created_at, "%e %B %Y").strip
  end

  # превью ли это топика?
  def preview?
    h.params[:action] != 'show'
  end

  # надо ли свёртывать длинный контент топика?
  def should_shorten?
    !news? || (news? && generated?) || (news? && object.body !~ /\[wall\]/)
  end

  # показывать ли тело топика?
  def show_body?
    preview? || !generated? || contest? || review?
  end

  # по опросу ли данный топик
  def contest?
    object.class == ContestComment
  end

  # есть ли свёрнутые комментарии?
  def folded?
    folded_comments > 0
  end

  # число свёрнутых комментариев
  def folded_comments
    object.comments_count - comments_limit
  end

  # число отображаемых напрямую комментариев
  def comments_limit
    preview? ? (h.params[:page] && h.params[:page] > 1 ? 1 : 3) : FOLD_LIMIT
  end

  # посты топика
  def comments
    object
      .comments
      .with_viewed(h.current_user)
      .limit(comments_limit)
      .to_a
      .reverse

    #preview? ? comments : comments.reverse
  end

  # тег топика
  def tag
    return nil if linked.nil? || review? || contest?

    if linked.kind_of? Review
      h.localized_name linked.target
    else
      h.localized_name linked if linked.respond_to?(:name) && linked.respond_to?(:russian)
    end
  end

  # адрес заголовка топика
  def url
    preview? ? h.topic_url(object) : h.user_url(user)
  end

  # адрес текста топика
  def body_url
    h.entry_body_url object
  end

  # адрес прочих комментариев топика
  def comments_url
    h.fetch_comments_url id: comments.first.id, topic_id: object.id, skip: 'SKIP', limit: FOLD_LIMIT
  end

  # текст для свёрнутых комментариев
  def show_hidden_comments_text
    num = [folded_comments, FOLD_LIMIT].min
    text = "Показать #{Russian.p num, 'предыдущий', 'предыдущие', 'предыдущие'} #{num} #{Russian.p num, 'комментарий', 'комментария', 'комментариев'}%s" % [
        folded_comments < FOLD_LIMIT ? '' : "<span class=\"expandable-comments-count\"> (из #{folded_comments})</span>"
      ]
    text.html_safe
  end

  def new_comment
    Comment.new user: h.current_user, commentable: object
  end
end
