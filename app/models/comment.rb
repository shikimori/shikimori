# комментарии должны создаваться, обновляться и удаляться через CommentsService
# TODO: refactor fat model
class Comment < ActiveRecord::Base
  include PermissionsPolicy
  include Moderatable
  include Antispam
  include Viewable

  MIN_REVIEW_SIZE = 230

  # assiciations
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  belongs_to :topic,
    class_name: Entry.name,
    foreign_key: :commentable_id

  has_many :abuse_requests, -> { order :id }, dependent: :destroy
  has_many :bans, -> { order :id }

  has_many :messages, -> { where linked_type: Comment.name },
    foreign_key: :linked_id,
    dependent: :destroy

  # validations
  validates :body, :user, :commentable, presence: true
  validates_length_of :body, minimum: 2, maximum: 10000

  # scopes
  scope :summaries, -> { where review: true }

  # callbacks
  before_validation :clean
  before_validation :forbid_ban_change

  before_create :check_access
  before_create :cancel_summary

  after_create :increment_comments
  after_create :creation_callbacks
  after_create :notify_quotes
  after_save :release_the_banhammer!

  before_destroy :decrement_comments
  after_destroy :destruction_callbacks
  after_destroy :remove_replies

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # counter_cache hack
  def increment_comments
    if commentable && commentable.attributes['comments_count']
      commentable.increment!(:comments_count)
    end
  end
  def decrement_comments
    if commentable && commentable.attributes['comments_count']
      commentable.class.decrement_counter(:comments_count, commentable.id)
    end
  end

  # проверка можно ли добавлять комментарий в комментируемый объект
  def check_access
    commentable_klass = Object.const_get(commentable_type.to_sym)
    commentable = commentable_klass.find(commentable_id)
    if commentable.respond_to?(:can_be_commented_by?)
      return false unless commentable.can_be_commented_by?(self)
    end
  end

  # отмена метки отзыва для коротких комментариев
  def cancel_summary
    self.review = false if review? && body.size < MIN_REVIEW_SIZE
    true
  end

  # для комментируемого объекта вызов колбеков, если они определены
  def creation_callbacks
    commentable_klass = Object.const_get(self.commentable_type.to_sym)
    commentable = commentable_klass.find(self.commentable_id)
    self.commentable_type = commentable.base_class.name if commentable.respond_to?(:base_class)

    commentable.comment_added(self) if commentable.respond_to?(:comment_added)
    #commentable.mark_as_viewed(self.user_id, self) if commentable.respond_to?(:mark_as_viewed)

    self.save if self.changed?
  end

  # для комментируемого объекта вызов колбеков, если они определены
  def destruction_callbacks
    commentable_klass = Object.const_get(self.commentable_type.to_sym)
    commentable = commentable_klass.find(self.commentable_id)

    commentable.comment_deleted(self) if commentable.respond_to?(:comment_deleted)
  rescue ActiveRecord::RecordNotFound
  end

  # убираение комментария из ответов
  def remove_replies
    notified_comments = []

    ExtractQuoted.new(body).perform.each do |(quoted_comment, _)|
      if quoted_comment && !notified_comments.include?(quoted_comment.id)
        notified_comments << quoted_comment.id
        ReplyService.new(quoted_comment).remove_reply self
      end
    end
  end

  # уведомление для цитируемых пользователей о том, что им ответили
  def notify_quotes
    notified_comments = []
    notified_users = []

    ExtractQuoted.new(body).perform.each do |(quoted_comment,quoted_user)|
      if quoted_comment && !notified_comments.include?(quoted_comment.id)
        notified_comments << quoted_comment.id
        ReplyService.new(quoted_comment).append_reply self
      end

      # игнорируем цитаты самому себе и пользователей, которым уже создали уведомления
      if quoted_user && quoted_user.id != self.user_id &&
          !notified_users.include?(quoted_user.id) &&
          !quoted_user.ignores?(user)

        notified_users << quoted_user.id

        Message.create_wo_antispam!(
          from_id: user_id,
          to_id: quoted_user.id,
          kind: MessageType::QuotedByUser,
          linked: self
        )
      end
    end
  end

  # автобан за мат
  def release_the_banhammer!
    Banhammer.new(self).release
  end

  def clean
    self.body.strip! if self.body
  end

  # при изменении body будем менять и html_body для всех комментов, кроме содержащих правки модератора
  def body= text
    if text
      self[:body] = BbCodeFormatter.instance.preprocess_comment text
    else
      self[:body] = nil
    end
  end

  def html_body
    fixed_body = if commentable_id == 82468 && commentable_type == Entry.name
      body
        .gsub('[poster=', '[image=')
        .gsub('[poster]', '[img]')
        .gsub('[/poster]', '[/img]')
        .gsub(/\[img.*?\]/, '[img]')
        .gsub(/\[image=(\d+) .+?\]/, '[image=\1]')
    else
      body
    end

    BbCodeFormatter.instance.format_comment fixed_body
  end

  # оффтопик ли это?
  def offtopic?
    offtopic
  end

  # отзыв ли это?
  def review?
    review
  end

  # пометка комментария либо оффтопиком, либо обзором
  def mark kind, value
    if value && kind == 'offtopic'
      ids = quoted_responses.map(&:id) + [id]
      Comment.where(id: ids).update_all offtopic: true
      self.offtopic = true

      ids
    else
      update kind => value if respond_to? kind

      [id]
    end
  end

  # ветка с ответами на этот комментарий
  def quoted_responses
    comments = Comment
      .where("id > ?", id)
      .where(commentable_type: commentable_type, commentable_id: commentable_id)
      .order(:id)

    search_ids = Set.new [id]

    comments.each do |comment|
      search_ids.clone.each do |id|
        if comment.body.include?("[comment=#{id}]") || comment.body.include?("[quote=#{id};") || comment.body.include?("[quote=c#{id};")
          search_ids << comment.id
        end
      end
    end

    comments.select { |v| search_ids.include? v.id }
  end

  # запрет на изменение информации о бане
  def forbid_ban_change
    if changes['body']
      prior_ban = (changes['body'].first || '').match(/(\[ban=\d+\])/).try :[], 1
      current_ban = (changes['body'].last || '').match(/(\[ban=\d+\])/).try :[], 1

      prior_count = (changes['body'].first || '').scan(/(\[ban=\d+\])/).size
      current_count = (changes['body'].last || '').scan(/(\[ban=\d+\])/).size

      if prior_ban != current_ban || prior_count != current_count
        errors[:base] << I18n.t('activerecord.errors.models.comments.not_a_moderator')
      end
    end
  end

  def allowed_summary?
    commentable.instance_of?(Topics::EntryTopics::AnimeTopic) ||
      commentable.instance_of?(Topics::EntryTopics::MangaTopic)
  end
end
