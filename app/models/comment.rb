# комментарии должны создаваться, обновляться и удаляться через CommentsService
# TODO: refactor fat model
class Comment < ApplicationRecord
  include AntispamConcern
  include Moderatable
  include Viewable

  antispam(
    interval: 3.seconds,
    disable_if: -> { (user.admin? && Rails.env.development?) || user.bot? },
    user_id_key: :user_id
  )

  MIN_SUMMARY_SIZE = 230

  # associations
  belongs_to :user,
    touch: Rails.env.test? ? false : :activity_at
  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :topic,
    optional: true,
    class_name: 'Topic',
    foreign_key: :commentable_id,
    inverse_of: :comments

  has_many :abuse_requests, -> { order :id },
    dependent: :destroy,
    inverse_of: :comment
  has_many :bans, -> { order :id },
    inverse_of: :comment

  has_many :messages, -> { where linked_type: Comment.name },
    foreign_key: :linked_id,
    dependent: :destroy,
    inverse_of: :linked

  boolean_attributes :summary, :offtopic

  # validations
  validates :user, :body, :commentable, presence: true
  validates :commentable_type,
    inclusion: { in: Types::Comment::CommentableType.values }
  validates :body,
    length: { minimum: 2, maximum: 32_000 },
    if: -> { will_save_change_to_body? && summary? }

  validates :body,
    length: { minimum: 2, maximum: 10_000 },
    if: -> { will_save_change_to_body? && !summary? }

  # scopes
  scope :summaries, -> { where is_summary: true }

  # callbacks
  before_validation :forbid_tag_change, if: -> { will_save_change_to_body? }

  before_create :check_access
  before_create :cancel_summary
  before_create :check_spam_abuse, if: -> { commentable_type == User.name }
  after_create :increment_comments

  before_destroy :decrement_comments
  before_destroy :destroy_images

  after_destroy :touch_commentable
  after_destroy :remove_notifies

  after_save :release_the_banhammer!,
    if: -> { saved_change_to_body? && !@skip_banhammer }
  after_save :touch_commentable
  after_save :notify_quoted, if: -> { saved_change_to_body? }

  def commentable
    if association(:topic).loaded? && !topic.nil? && commentable_type == 'Topic'
      topic
    else
      super
    end
  end

  # отмена метки отзыва для коротких комментариев
  def cancel_summary
    return unless summary?
    return if body.size >= MIN_SUMMARY_SIZE && allowed_summary?

    self.is_summary = false
  end

  def check_spam_abuse
    unless Users::CheckHacked.call(model: self, text: body, user: user)
      throw :abort
    end
  end

  def notify_quoted
    Comments::NotifyQuoted.call(
      old_body: saved_changes[:body].first,
      new_body: saved_changes[:body].second,
      comment: self,
      user: user
    )
  end

  def remove_notifies
    Comments::NotifyQuoted.call(
      old_body: body,
      new_body: nil,
      comment: self,
      user: user
    )
  end

  def release_the_banhammer!
    Banhammer.instance.release! self
  end

  def touch_commentable
    if commentable.respond_to? :commented_at
      commentable.update_column :commented_at, Time.zone.now
    else
      commentable.update_column :updated_at, Time.zone.now
    end
  end

  # TODO: move to CommentDecorator
  def html_body
    fixed_body =
      if offtopic_topic?
        body
          .gsub(/\[poster=/i, '[image=')
          .gsub(/\[poster\]/i, '[img]')
          .gsub(%r{\[/poster\]}i, '[/img]')
          .gsub(/\[img.*?\]/i, '[img]')
          .gsub(/\[image=(\d+) .+?\]/i, '[image=\1]')
      else
        body
      end

    BbCodes::Text.call fixed_body, object: self
  end

  def mark_offtopic flag
    if flag
      # mark comment thread as offtopic
      ids = Comments::Replies.call(self).map(&:id) + [id]
      Comment
        .where.not(id: id)
        .where(id: ids)
        .update_all is_offtopic: flag, updated_at: Time.zone.now

      update is_offtopic: flag
      ids
    else
      # mark as not offtopic current comment only
      update is_offtopic: flag
      [id]
    end
  end

  def mark_summary flag
    update is_summary: flag
    [id]
  end

  def forbid_tag_change # rubocop:disable all
    [/(\[ban=\d+\])/, /\[broadcast\]/].each do |tag|
      prior_ban = (changes_to_save[:body].first || '').match(tag).try :[], 1
      current_ban = (changes_to_save[:body].last || '').match(tag).try :[], 1

      prior_count = (changes_to_save[:body].first || '').scan(tag).size
      current_count = (changes_to_save[:body].last || '').scan(tag).size

      if prior_ban != current_ban || prior_count != current_count
        errors[:base] << I18n.t('activerecord.errors.models.comments.not_a_moderator')
      end
    end
  end

  def allowed_summary?
    commentable.instance_of?(Topics::EntryTopics::AnimeTopic) ||
      commentable.instance_of?(Topics::EntryTopics::MangaTopic) ||
        commentable.instance_of?(Topics::EntryTopics::RanobeTopic)
  end

  def moderatable?
    (
      commentable_type == Topic.name &&
        commentable.linked_type != Club.name &&
        commentable.linked_type != ClubPage.name
    ) || commentable_type == Review.name
  end

  def faye_channels
    %W[/comment-#{id}]
  end

private

  def offtopic_topic?
    return false if topic.blank?

    topic.id == Topic::TOPIC_IDS[:offtopic][topic.locale.to_sym]
  end

  # counter_cache hack
  def increment_comments
    if commentable && commentable.attributes['comments_count']
      commentable.increment! :comments_count
    end
  end

  def decrement_comments
    if commentable && commentable.attributes['comments_count']
      commentable.class.decrement_counter :comments_count, commentable.id
    end
  end

  def destroy_images
    Comment::Cleanup.call self, is_cleanup_summaries: true, skip_model_update: true
  end

  # TODO: get rid of this method
  # проверка можно ли добавлять комментарий в комментируемый объект
  def check_access
    commentable = commentable_klass.find(commentable_id)

    if commentable.respond_to?(:can_be_commented_by?) &&
        !commentable.can_be_commented_by?(self)
      throw :abort
    end
  end

  def commentable_klass
    @commentable_klass ||= Object.const_get commentable_type.to_sym
  end
end
