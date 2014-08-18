# TODO: refactor to decorator
class TopicPresenter < BasePresenter
  prepend ActiveCacher.instance

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

  # rel аттрибут ссылки топика
  def rel
    @with_user || @blocked_rel ? '' : 'history'
  end

  ## создан ли топик автоматически?
  #def generated?
    #Entry::SpecialTypes.include?(entry.class.name) || contest?
  #end

  # объект топика
  def topic
    entry
  end

  # отображать ли дату создания топика
  def with_date?
    @with_user
  end

  # большая ли у топика аватарка?
  #def extended_image?
    #(entry.special? && entry.linked.respond_to?(:image)) || review?
  #end

  # связанный с новостью элемент
  def linked
    @linked ||= entry.linked
  end
end
