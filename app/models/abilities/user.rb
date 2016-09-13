class Abilities::User
  include CanCan::Ability

  def initialize user
    @user = user

    topic_abilities
    comment_abilities
    message_abilities
    user_abilities
    user_rate_abilities
    review_abilities
    club_abilities
    anime_video_abilities
    version_abilities
    other_abilities
  end

  def topic_abilities
    can [:new, :create], [Topic, Topics::NewsTopic.name] do |topic|
      !@user.banned? && @user.week_registered? &&
        topic.user_id == @user.id
    end
    can [:update], [Topic, Topics::NewsTopic.name] do |topic|
      !@user.banned? && topic.user_id == @user.id
    end
    can [:destroy], [Topic, Topics::NewsTopic.name] do |topic|
      can?(:create, topic) && topic.created_at + 1.day > Time.zone.now
    end
    can [:create, :destroy], [TopicIgnore] do |topic_ignore|
      topic_ignore.user_id == @user.id
    end
  end

  def comment_abilities
    can [:new, :create], [Comment] do |comment|
      !@user.banned? && @user.day_registered? &&
        comment.user_id == @user.id
    end
    can [:update], [Comment] do |comment|
      can?(:create, comment) && comment.created_at + 1.day > Time.zone.now
    end
    can [:destroy], [Comment] do |comment|
      can? :update, comment
    end
  end

  def message_abilities
    can [:mark_read], Message # пометка сообщений прочтёнными
    can [:read], Message do |message|
      message.from_id == @user.id || message.to_id == @user.id
    end
    can [:destroy], Message do |message|
      message.from_id == @user.id || message.to_id == @user.id
      #(message.kind == MessageType::Private && (can?(:edit, message) || message.to_id == @user.id)) ||
        #(message.kind != MessageType::Private && (message.from_id == @user.id || message.to_id == @user.id))
    end
    can [:create], Message do |message|
      !@user.forever_banned? && message.kind == MessageType::Private &&
        message.from_id == @user.id
    end
    can [:edit, :update], Message do |message|
      message.kind == MessageType::Private &&
        message.from_id == @user.id &&
          message.created_at + 10.minutes > Time.zone.now
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
    can [:cleanup, :reset], UserRate
  end

  def review_abilities
    can :manage, Review do |review|
      !@user.banned? && @user.day_registered? && review.user_id == @user.id
    end
  end

  def club_abilities
    can [:new, :create, :update], Club do |club|
      !@user.banned? && @user.day_registered? && (club.owner?(@user) || club.admin?(@user))
    end
    can :join, Club do |club|
      !club.joined?(@user) && (
        can?(:manage, club) || (!club.banned?(@user) && club.free_join?)
      )
    end
    can :invite, Club do |club|
      club.joined?(@user) && (
        club.free_join? ||
        (club.admin_invite_join? && (club.admin?(@user) || club.owner?(@user))) ||
        (club.owner_invite_join? && club.owner?(@user))
      )
    end
    can :leave, Club do |club|
      club.joined? @user
    end
    can :upload, Club do |club|
      if club.upload_policy == ClubUploadPolicy::ByStaff
        !@user.banned? && (club.owner?(@user) || club.admin?(@user))

      elsif club.upload_policy == ClubUploadPolicy::ByMembers
        !@user.banned? && (club.joined?(@user) && club.display_images)

      else
        raise ArgumentError, club.upload_policy
      end
    end

    can :create, ClubRole do |club_role|
      club_role.user_id == @user.id && can?(:join, club_role.club)
    end
    can :destroy, ClubRole do |club_role|
      club_role.user_id == @user.id
    end

    can [:accept, :reject], ClubInvite, dst_id: @user.id
    can :create, ClubInvite do |club_invite|
      club_invite.src_id == @user.id && club_invite.club.joined?(@user)
    end
  end

  def anime_video_abilities
    can [:create], AnimeVideoReport do |report|
      !@user.banned? && report.user_id == @user.id &&
        (report.broken? || report.wrong?)
    end
    can [:new, :create], AnimeVideo do |anime_video|
      !@user.banned? && anime_video.uploaded?
    end
    can [:edit, :update], AnimeVideo do |anime_video|
      !@user.banned? && (anime_video.uploaded? || anime_video.working?)
    end
    can [:destroy], AnimeVideo do |anime_video|
      !@user.banned? &&
        (anime_video.uploader == @user && (
          @user.api_video_uploader? || anime_video.created_at > 1.week.ago))
    end
  end

  def version_abilities
    can [:create, :destroy], Version do |version|
      !@user.banned? && version.user_id == @user.id && (
        version.item_diff.keys & version.item_type.constantize::SIGNIFICANT_FIELDS
      ).none?
    end
    cannot [:significant_change], Version
  end

  def other_abilities
    can :destroy, Image do |image|
      image.uploader_id == @user.id || can?(:edit, image.owner)
    end
    can :manage, Device, user_id: @user.id
    can :read, Genre
  end
end
