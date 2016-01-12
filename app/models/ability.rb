class Ability
  include CanCan::Ability

  def initialize user
    define_abilities

    @user = user
    guest_ability

    if @user
      user_ability
      moderator_ability if @user.moderator?
      contests_moderator_ability if @user.contests_moderator?
      reviews_moderator_ability if @user.reviews_moderator?
      video_moderator_ability if @user.video_moderator?
      versions_moderator_ability if @user.versions_moderator?
      admin_ability if @user.admin?
    end
  end

  def define_abilities
    #alias_action :read, to: :see_profile
    alias_action :current, :read, :users, :comments, :grid, to: :see_contest
    alias_action :read, :comments, :animes, :mangas, :characters, :members, :images, to: :see_club
  end

  def guest_ability
    can :access_list, User do |user|
      user.preferences.list_privacy_public?
    end
    can :see_contest, Contest
    can :see_club, Club
    can :read, Review

    can [:create], Message do |message|
      message.kind == MessageType::Private &&
        message.from_id == User::GUEST_ID && message.to_id == User::ADMINS.first
    end

    can [:create], AnimeVideoReport do |report|
      report.user_id == User::GUEST_ID && (report.broken? || report.wrong?)
    end
    can [:new, :create], AnimeVideo do |anime_video|
      anime_video.uploaded?
    end

    can [:create], Version do |version|
      version.user_id == User::GUEST_ID && (
        version.item_diff.keys & version.item_type.constantize::SIGNIFICANT_FIELDS
      ).none?
    end
    cannot [:significant_change], Version
    can [:show, :tooltip], Version
    can :tooltip, Genre
  end

  def user_ability
    can :manage, UserRate, user_id: @user.id
    can :manage, UserToken, user_id: @user.id
    can [:cleanup, :reset], UserRate

    can :destroy, Image do |image|
      image.uploader_id == @user.id || can?(:edit, image.owner)
    end

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

    can [:accept, :reject], ClubInvite, dst_id: @user.id, status: ClubInviteStatus::Pending
    can :create, ClubInvite do |club_invite|
      club_invite.src_id == @user.id && club_invite.club.joined?(@user)
    end

    can :manage, Review do |review|
      !@user.banned? && @user.day_registered? && review.user_id == @user.id
    end

    can :manage, Device, user_id: @user.id

    can [:new, :create], [Entry, Topic, Topics::NewsTopic.name] do |topic|
      !@user.banned? && @user.day_registered? &&
        topic.user_id == @user.id
    end
    can [:update], [Entry, Topic, Topics::NewsTopic.name] do |topic|
      can? :create, topic
    end
    can [:destroy], [Entry, Topic, Topics::NewsTopic.name] do |topic|
      can?(:create, topic) && topic.created_at + 4.hours > Time.zone.now
    end
    can [:create, :destroy], [TopicIgnore] do |topic_ignore|
      topic_ignore.user_id == @user.id
    end

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
        (anime_video.uploader == @user && anime_video.created_at > 1.week.ago)
    end

    can [:create, :destroy], Version do |version|
      !@user.banned? && version.user_id == @user.id && (
        version.item_diff.keys & version.item_type.constantize::SIGNIFICANT_FIELDS
      ).none?
    end
    cannot [:significant_change], Version
    can :read, Genre
  end

  def moderator_ability
    can :manage, [Entry, Topic, Topics::NewsTopic.name, Review]
    can [:edit, :update], [Genre]
  end

  def contests_moderator_ability
    can :manage, Contest
    cannot :destroy, Contest
  end

  def reviews_moderator_ability
    can :manage, Review
  end

  def video_moderator_ability
    can :manage, AnimeVideoReport
    can [:new, :create, :edit, :update], AnimeVideo do |anime_video|
      !@user.banned? && !anime_video.banned? && !anime_video.copyrighted?
    end
  end

  def versions_moderator_ability
    can :manage, Version
  end

  def admin_ability
    can :manage, :all
  end
end
