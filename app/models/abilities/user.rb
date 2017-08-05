class Abilities::User
  include CanCan::Ability
  prepend Draper::CanCanCan

  GENERATED_USER_TOPICS = [
    Topics::EntryTopics::ReviewTopic.name,
    Topics::EntryTopics::CollectionTopic.name
  ]

  USER_TOPIC_TYPES = [
    # nil for NEW topic button when user must choose type between News and Topic
    nil,
    Topic.name,
    Topics::NewsTopic.name
  ] + GENERATED_USER_TOPICS

  def initialize user
    @user = user

    unless @user.banned?
      topic_abilities if @user.week_registered?
      comment_abilities if @user.day_registered?
      review_abilities if @user.week_registered?
      collection_abilities if @user.week_registered?
      other_abilities
      club_abilities
    end

    topic_ignores_abilities
    message_abilities
    user_abilities
    user_rate_abilities
    anime_video_abilities
    version_abilities
    style_abilities
    list_import_abilities
    poll_abilities
  end

  def topic_abilities
    can %i[new edit create update], Topic do |topic|
      topic.user_id == @user.id &&
        (
          USER_TOPIC_TYPES.include?(topic.type) || (
            topic.type == Topics::ClubUserTopic.name &&
            can?(:create_topic, topic.linked)
          )
        )
    end
    can :destroy, Topic do |topic|
      (can?(:create, topic) && topic.created_at + 1.day > Time.zone.now) || (
        topic.type == Topics::ClubUserTopic.name &&
        can?(:create_topic, topic.linked) &&
        topic.comments_count < 2_000
      )
    end
    can :broadcast, Topic do |topic|
      can_broadcast_in_club_topic?(topic, @user)
    end
  end

  def topic_ignores_abilities
    can %i[create destroy], TopicIgnore do |topic_ignore|
      topic_ignore.user_id == @user.id
    end
  end

  def comment_abilities
    can %i[new create], Comment do |comment|
      comment.user_id == @user.id
    end
    can :update, Comment do |comment|
      (
        can?(:create, comment) && comment.created_at + 1.day > Time.zone.now
      ) || (
        comment.commentable_type == User.name &&
        comment.commentable_id == @user.id &&
        comment.user_id == @user.id
      ) || can_update_club_comment?(comment, @user)
    end
    can [:destroy], Comment do |comment|
      can?(:update, comment) || (
        comment.commentable_type == User.name &&
        comment.commentable_id == @user.id
      ) || can_destroy_club_comment?(comment, @user)
    end
    can [:broadcast], Comment do |comment|
      can_broadcast_in_club_topic?(comment.commentable, @user)
    end
  end

  def message_abilities
    can :mark_read, Message # пометка сообщений прочтёнными
    can :read, Message do |message|
      message.from_id == @user.id || message.to_id == @user.id
    end
    can :destroy, Message do |message|
      message.from_id == @user.id || message.to_id == @user.id
      #(message.kind == MessageType::Private && (can?(:edit, message) || message.to_id == @user.id)) ||
        #(message.kind != MessageType::Private && (message.from_id == @user.id || message.to_id == @user.id))
    end
    can %i[create edit update], Message do |message|
      !@user.forever_banned? && message.kind == MessageType::Private &&
        message.from_id == @user.id
    end
  end

  def user_abilities
    can :access_list, User do |user|
      if user == @user || user.preferences.list_privacy_public? || user.preferences.list_privacy_users?
        true
      elsif user.preferences.list_privacy_friends? && user.friended?(@user)
        true
      else
        false
      end
    end
    can :access_messages, User do |user|
      user == @user
    end
    can [:edit, :update], User do |user|
      user == @user || @user.admin?
    end

    can :manage, UserToken, user_id: @user.id
  end

  def user_rate_abilities
    can :manage, UserRate, user_id: @user.id
    can %i[cleanup reset], UserRate
  end

  def review_abilities
    can :manage, Review do |review|
      review.user_id == @user.id
    end
  end

  def collection_abilities
    can :manage, Collection do |collection|
      collection.user_id == @user.id
    end
  end

  def club_abilities
    can %i[new create], Club do |club|
      @user.week_registered? && club.owner?(@user)
    end
    can :update, Club do |club|
      club.owner?(@user) || club.admin?(@user)
    end
    can :broadcast, Club do |club|
      club.owner?(@user) || club.admin?(@user)
    end
    can :join, Club do |club|
      !club.member?(@user) && (
        can?(:manage, club) || club.owner?(@user) ||
        (!club.banned?(@user) && club.join_policy_free?)
      )
    end
    can :invite, Club do |club|
      club.member?(@user) && (
        club.join_policy_free? ||
        (club.join_policy_admin_invite? && (club.admin?(@user) || club.owner?(@user))) ||
        (club.join_policy_owner_invite? && club.owner?(@user))
      )
    end
    can :leave, Club do |club|
      club.member? @user
    end
    can :create_topic, Club do |club|
      (club.topic_policy_members? && club.member?(@user)) ||
        (club.topic_policy_admins? && club.admin?(@user))
    end
    can :upload_image, Club do |club|
      (club.image_upload_policy_members? && club.member?(@user)) ||
        (club.image_upload_policy_admins? && club.admin?(@user))
    end

    can %i[new create update destroy up down], ClubPage do |club_page|
      can?(:update, club_page.club) && (
        club_page.parent_page_id.nil? ||
        club_page.parent_page.club_id == club_page.club_id
      )
    end

    can :create, ClubRole do |club_role|
      club_role.user_id == @user.id && can?(:join, club_role.club)
    end
    can :destroy, ClubRole do |club_role|
      club_role.user_id == @user.id
    end

    can %i[accept reject], ClubInvite, dst_id: @user.id
    can :create, ClubInvite do |club_invite|
      club_invite.src_id == @user.id && club_invite.club.member?(@user)
    end
  end

  def anime_video_abilities
    can :create, AnimeVideoReport do |report|
      !@user.banned? && !@user.verison_vermin? &&
        report.user_id == @user.id && (
          report.broken? || report.wrong? || report.other?
        )
    end
    can %i[new create], AnimeVideo do |anime_video|
      !@user.banned? && !@user.verison_vermin? && anime_video.uploaded?
    end
    can %i[edit update], AnimeVideo do |anime_video|
      !@user.banned? && !@user.verison_vermin? &&
        (anime_video.uploaded? || anime_video.working?)
    end
    can :destroy, AnimeVideo do |anime_video|
      !@user.banned? && !@user.verison_vermin? &&
        (anime_video.uploader == @user && (
          @user.api_video_uploader? || anime_video.created_at > 1.week.ago)
        )
    end
  end

  def version_abilities
    can %i[create destroy], Version do |version|
      !@user.banned? && !@user.verison_vermin? &&
        version.user_id == @user.id && (
          version.item_diff.keys & version.item_type.constantize::SIGNIFICANT_FIELDS
        ).none?
    end
    cannot :significant_change, Version

    can :accept, Version do |version|
      version.user_id == @user.id && (
        @user.trusted_version_changer? || (
          version.is_a?(Versions::CollectionVersion) &&
          @user.trusted_ranobe_external_links_changer? &&
            version.item.ranobe? &&
            version.item_diff.keys == ['external_links']
        )
      )
    end
  end

  def style_abilities
    can %i[create update], Style do |style|
      if style.owner_type == User.name
        style.owner_id == @user.id
      elsif style.owner_type == Club.name
        can? :update, style.owner
      end
    end
    # can :destroy, Style do |style|
      # can?(:update, style) && @user.style_id != style.id
    # end
  end

  def other_abilities
    can :create, ClubImage do |image|
      can?(:upload_image, image.club) && image.user == @user
    end

    can :destroy, ClubImage do |image|
      (image.club.member?(@user) && image.user == @user) ||
        image.club.admin?(@user)
    end

    can :manage, Device, user_id: @user.id
    can :read, Genre
  end

  def list_import_abilities
    can %i[new create show], ListImport do |list_import|
      list_import.user_id == @user.id
    end
  end

  def poll_abilities
    can %i[new create edit update destroy], Poll do |poll|
      poll.user_id == @user.id && poll.pending?
    end

    can %i[start], Poll do |poll|
      poll.user_id == @user.id && poll.can_start?
    end

    can %i[stop], Poll do |poll|
      poll.user_id == @user.id && poll.can_stop?
    end
  end

private

  def can_update_club_comment? comment, user
    comment.user_id == user.id && club_admin?(comment.commentable, user)
  end

  def can_destroy_club_comment? comment, user
    club_admin? comment.commentable, user
  end

  def can_broadcast_in_club_topic? commentable, user
    club_admin? commentable, user
  end

  def club_admin? commentable, user
    (
      commentable.is_a?(Topics::EntryTopics::ClubTopic) &&
      user.club_admin_roles.any? { |v| v.club_id == commentable.linked_id }
    ) || (
      commentable.is_a?(Topics::ClubUserTopic) &&
      user.club_admin_roles.any? { |v| v.club_id == commentable.linked_id }
    ) || (
      commentable.is_a?(Topics::EntryTopics::ClubPageTopic) &&
      user.club_admin_roles.any? { |v| v.club_id == commentable.linked.club_id }
    )
  end
end
