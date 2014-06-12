# права на действия с различными сущностями
module PermissionsPolicy
  def self.included(base)
    base.send :include, PermissionsPolicy.const_get(base.name+'Permissions')
  end

  module Defaults
    # 2043 - laitqwerty
    # 85018 - топик фака
    def can_be_edited_by?(user)
      user && (
        (user.id == 2043 && self.respond_to?(:commentable_type) && self.commentable_type == Topic.base_class.name && self.commentable_id == 85018) ||
        (user.id == 2043 && self.class == Topic && self.id == 85018) ||
        (user.id == self.user_id && ((self.respond_to?(:moderated?) && self.moderated?) || self.kind_of?(Entry) || (self.created_at + 1.day > Time.zone.now))) || user.moderator?
      )
    end

    def can_be_deleted_by?(user)
      user && (
        (user.id == 2043 && self.respond_to?(:commentable_type) && self.commentable_type == Topic.base_class.name && self.commentable_id == 85018) ||
        (user.id == self.user_id && self.created_at + 1.day > Time.zone.now) || user.moderator?
      )
    end
  end

  # права на действия с комментариями
  module CommentPermissions
    include Defaults

    def can_be_edited_by?(user)
      super
    end

    def can_be_deleted_by?(user)
      super || (user && commentable_type == User.name && commentable_id == user.id)
    end

    def can_cancel_offtopic?(user)
      can_be_deleted_by?(user) || user.abuse_requests_moderator?
    end
  end

  # права на изменение контестов
  module ContestPermissions
    def can_be_edited_by?(user)
      user && user.contests_moderator?
    end
  end

  # права на действия с топиками
  module EntryPermissions
    include Defaults

    def can_be_edited_by?(user)
      !self.generated? && super
    end

    def can_be_deleted_by?(user)
      !self.generated? && super
    end
  end

  # права на действия с обзорами
  module ReviewPermissions
    include Defaults

    def can_be_edited_by?(user)
      super || (user && user.id == self.user_id && self.created_at + 1.month > Time.zone.now)
    end
  end

  # права на действия с Пользователями
  module UserPermissions
    def can_be_edited_by?(user)
      user && user.id == self.id
    end

    # может профиль пользователя быть прокомментирован комментарием
    def can_be_commented_by?(comment)
      unless self.ignores.any? {|v| v.target_id == comment.user_id }
        true
      else
        comment.errors[:forbidden] = User::CommentForbiddenMessage
        false
      end
    end
  end

  # права на действия с Группами
  module GroupPermissions
    # может ли пользователь редактировать группу?
    def can_be_edited_by?(user)
      user && (user.admin? || staff?(user))
    end

    # может ли пользователь вступить группу?
    def can_be_joined_by?(user)
      user && (user.id == owner_id || (free_join? && !banned?(user)))
    end

    # может ли пользователь загружать картинку
    def can_be_uploaded_by?(user)
      if upload_policy == GroupUploadPolicy::ByMembers
        member?(user)
      elsif self.upload_policy == GroupUploadPolicy::ByStaff
        staff?(user)
      else
        false
      end
    end

    # может ли пользователь посылать приглашения в эту группу?
    def can_send_invites?(user)
      if free_join?
        members.include?(user)
      elsif owner_invite_join?
        members.include?(user) && owner_id == user.id
      else
        false
      end
    end

    def can_delete_images?(user)
      staff?(user)
    end

    def can_delete_videos?(user)
      staff?(user)
    end
  end

  # права на действия с Топиком группы
  module GroupCommentPermissions
    # может ли комментарий быть создан пользователем
    def can_be_commented_by?(comment)
      if linked.free_comment?
        if linked.banned?(comment.user)
          comment.errors[:forbidden] = I18n.t('activerecord.errors.models.comments.in_club_black_list')
          false
        else
          true
        end

      elsif linked.members_comment?
        if linked.member?(comment.user_id)
          true
        else
          comment.errors[:forbidden] = I18n.t('activerecord.errors.models.comments.not_a_club_member')
          false
        end
      else
        raise ArgumentError, linked.comment_policy
      end
    end
  end

  module ImagePermissions
    def can_be_deleted_by?(user)
      user.id == self.uploader_id || (self.owner.respond_to?(:can_delete_images?) && self.owner.can_delete_images?(user))
    end
  end

  module AbuseRequestPermissions
    def can_process?(user)
      user.abuse_requests_moderator?
    end
  end
end
