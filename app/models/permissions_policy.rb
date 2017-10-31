# TODO: refactor this code
module PermissionsPolicy
  def self.included(base)
    base.send :include, PermissionsPolicy.const_get(base.name+'Permissions')
  end

  module Defaults
    # 2043 - laitqwerty
    # 85018 - топик фака
    def can_be_edited_by?(user)
      user && (
        (
          user.id == self.user_id && (
            (self.respond_to?(:moderated?) && self.moderated?) ||
            self.kind_of?(Topic) ||
            (self.created_at + 1.day > Time.zone.now)
          )
        ) || user.forum_moderator?
      )
    end

    def can_be_deleted_by?(user)
      user && (
        (user.id == self.user_id && self.created_at + 1.day > Time.zone.now) ||
          user.forum_moderator?
      )
    end
  end

  # права на действия с комментариями
  # module CommentPermissions
    # include Defaults

    # def can_be_edited_by?(user)
      # super || (user && commentable_type == User.name && commentable_id == user.id && user_id == user.id)
    # end

    # def can_be_deleted_by?(user)
      # super || (user && commentable_type == User.name && commentable_id == user.id)
    # end

    # def can_cancel_offtopic?(user)
      # can_be_deleted_by?(user) || user.forum_moderator?
    # end
  # end

  # права на действия с топиками
  module TopicPermissions
    include Defaults

    def can_be_edited_by?(user)
      !self.generated? && super
    end

    def can_be_deleted_by?(user)
      !self.generated? && super
    end
  end

  # права на действия с Пользователями
  module UserPermissions
    def can_be_edited_by?(user)
      user && user.id == self.id
    end

    # может профиль пользователя быть прокомментирован комментарием
    def can_be_commented_by?(comment)
      return true if comment.user_id == id

      if self.ignores.any? {|v| v.target_id == comment.user_id }
        comment.errors[:base].push(
          I18n.t('activerecord.errors.models.messages.ignored')
        )
        false
      elsif self.preferences.comment_policy_users?
        true
      elsif self.preferences.comment_policy_friends?
        if self.friended? comment.user
          true
        else
          comment.errors[:base].push(
            I18n.t('activerecord.errors.models.comments.not_a_friend')
          )
          false
        end
      elsif self.preferences.comment_policy_owner?
        comment.errors[:base].push(
          I18n.t('activerecord.errors.models.comments.not_a_owner')
        )
        false
      end
    end
  end

  # права на действия с Топиком группы
  module Topics::EntryTopics::ClubTopicPermissions
    # может ли комментарий быть создан пользователем
    def can_be_commented_by?(comment)
      if club.comment_policy_free?
        if club.banned? comment.user
          comment.errors[:base].push(
            I18n.t('activerecord.errors.models.comments.in_club_black_list')
          )
          false
        else
          true
        end

      elsif club.comment_policy_members?
        if club.member? comment.user
          true
        else
          comment.errors[:base].push(
            I18n.t('activerecord.errors.models.comments.not_a_club_member')
          )
          false
        end
      else
        raise ArgumentError, club.comment_policy
      end
    end
  end
end
