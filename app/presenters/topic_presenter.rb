# TODO: refactor to decorator
class TopicPresenter < BasePresenter
  prepend ActiveCacher

  CommentsFoldLimit = 20

  presents :entry
  proxy :id, :created_at, :section, :user, :viewed?, :can_be_edited_by?, :can_be_deleted_by?, :generated?, :news?, :review?

  instance_cache :comments, :folded_comments

  attr_accessor :limit, :fold_limit

  def initialize(options)
    super(options[:object], options[:template])

    @limit = options[:limit]
    @fold_limit = options[:fold_limit] || CommentsFoldLimit
    @with_user = options[:with_user]
    @linked = options[:linked]
    @blocked_rel = options[:blocked_rel]
  end

  # адрес заголовка топика
  def url
    @with_user ? user_url(user) : topic_url(entry)
  end

  # rel аттрибут ссылки топика
  def rel
    @with_user || @blocked_rel ? '' : 'history'
  end

  # адрес текста топика
  def body_url
    entry_body_url entry
  end

  # адрес прочих комментариев топика
  def comments_url
    @view_context.fetch_comments_url id: comments.first.id, topic_id: entry.id, skip: 'SKIP', limit: @fold_limit
  end

  # имя топика
  def topic_title
    if @with_user
      user.nickname
    elsif contest?
      entry.title
    elsif @linked # для топиков при указанном linked будет короткое название
      if @linked.respond_to? :name
        "#{entry.to_s} #{@linked.name}"
      else
        entry.to_s
      end
    #elsif entry.respond_to?(:linked) && entry.linked # надо подумать, стоит ли топики переименовывать
      #UserPresenter.localized_name entry.linked, current_user
    elsif entry.respond_to? :title
      entry.title
    else
      entry.name
    end
  end

  # текст топика
  def body
    BbCodeFormatter.instance.format_comment entry.body
  end

  # посты топика
  def comments
    entry.comments.with_viewed(current_user).limit(@limit).to_a
  end

  ## создан ли топик автоматически?
  #def generated?
    #Entry::SpecialTypes.include?(entry.class.name) || contest?
  #end

  # объект топика
  def topic
    entry
  end

  # объект топика
  def folded_comments
    entry.comments_count - @limit
  end

  # текст для свёрнутых комментариев
  def show_hidden_comments_text
    num = [folded_comments, @fold_limit].min
    text = "Показать #{Russian.p(num, 'предыдущий', 'предыдущие', 'предыдущие')} #{num} #{Russian.p(num, 'комментарий', 'комментария', 'комментариев')}%s" % [
        folded_comments < @fold_limit ? '' : "<span class=\"expandable-comments-count\"> (из #{folded_comments})</span>"
      ]
    text.html_safe
  end

  # есть ли свёрнутые комментарии?
  def folded?
    folded_comments > 0
  end

  # отображать ли дату создания топика
  def with_date?
    @with_user
  end

  # дата создания топика
  def date
    Russian::strftime(created_at, "%e %B %Y")
  end

  # большая ли у топика аватарка?
  def extended_image?
    (entry.special? && entry.linked.respond_to?(:image)) || review?
  end

  # картинка топика(аватарка автора)
  def avatar
    if entry.special? && entry.linked.respond_to?(:image) && !(entry.news? && !entry.generated? && !preview?)
      topic.linked.image.url(:x96)
    elsif entry.special? && entry.linked.respond_to?(:logo)
      topic.linked.logo.url(:x48)
    elsif review?
      topic.linked.entry.image.url(:x96)
    else
      entry.user.avatar_url(48)
    end
  end

  # превью ли это топика?
  def preview?
    !@with_user
  end

  # показывать ли тело топика?
  def show_body?
    preview? || !generated? || contest? || review?
  end

  # связанный с новостью элемент
  def linked
    @linked ||= entry.linked
  end

  # тег топика
  def tag
    return nil if linked.nil? || review? || contest?

    if linked.kind_of? Review
      localized_name linked.target
    else
      localized_name linked if linked.respond_to?(:name) && linked.respond_to?(:russian)
    end
  end

  # по опросу ли данный топик
  def contest?
    entry.class == ContestComment
  end

  # надо ли свёртывать длинный контент топика?
  def should_shorten?
    !news? || (news? && generated?) || (news? && entry.body !~ /\[wall\]/)
  end
end
