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
    can :see_club, Group
    can :read, Review

    can [:create], Message do |message|
      message.kind == MessageType::Private && message.from_id == User::GuestID && message.to_id == User::Admins.first
    end

    can [:create], AnimeVideoReport do |report|
      report.user_id == User::GuestID && (report.broken? || report.wrong?)
    end
    can [:new, :create], AnimeVideo do |anime_video|
      anime_video.uploaded?
    end
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

    can [:new, :create, :update], Group do |group|
      !@user.banned? && @user.day_registered? && (group.owner?(@user) || group.admin?(@user))
    end
    can :join, Group do |group|
      !group.joined?(@user) && (
        can?(:manage, group) || (!group.banned?(@user) && group.free_join?)
      )
    end
    can :invite, Group do |group|
      group.joined?(@user) && (
        group.free_join? ||
        (group.admin_invite_join? && (group.admin?(@user) || group.owner?(@user))) ||
        (group.owner_invite_join? && group.owner?(@user))
      )
    end
    can :leave, Group do |group|
      group.joined? @user
    end
    can :upload, Group do |group|
      if group.upload_policy == GroupUploadPolicy::ByStaff
        !@user.banned? && (group.owner?(@user) || group.admin?(@user))

      elsif group.upload_policy == GroupUploadPolicy::ByMembers
        !@user.banned? && (group.joined?(@user) && group.display_images)

      else
        raise ArgumentError, group.upload_policy
      end
    end

    can :create, GroupRole do |group_role|
      group_role.user_id == @user.id && can?(:join, group_role.group)
    end
    can :destroy, GroupRole do |group_role|
      group_role.user_id == @user.id
    end

    can [:accept, :reject], GroupInvite, dst_id: @user.id, status: GroupInviteStatus::Pending
    can :create, GroupInvite do |group_invite|
      group_invite.src_id == @user.id && group_invite.group.joined?(@user)
    end

    can :manage, Review do |review|
      !@user.banned? && @user.day_registered? && review.user_id == @user.id
    end

    can :manage, Device, user_id: @user.id

    can [:new, :create], [Topic, AnimeNews, MangaNews] do |topic|
      !@user.banned? && @user.day_registered? && topic.user_id == @user.id
    end
    can [:update], [Topic, AnimeNews, MangaNews] do |topic|
      !@user.banned? && (
        topic.user_id == @user.id# && topic.created_at + 3.months > Time.zone.now
      )
    end
    can [:destroy], [Topic, AnimeNews, MangaNews] do |topic|
      !@user.banned? && (
        topic.user_id == @user.id && topic.created_at + 4.hours > Time.zone.now
      )
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
      !@user.forever_banned? && message.kind == MessageType::Private && message.from_id == @user.id
    end
    can [:edit, :update], Message do |message|
      message.kind == MessageType::Private &&
        message.from_id == @user.id && message.created_at + 10.minutes > Time.zone.now
    end

    can [:create], AnimeVideoReport do |report|
      !@user.banned? && report.user_id == @user.id && (report.broken? || report.wrong?)
    end
    can [:new, :create], AnimeVideo do |anime_video|
      !@user.banned? && anime_video.uploaded?
    end
    can [:edit, :update], AnimeVideo do |anime_video|
      !@user.banned? && (anime_video.uploaded? || anime_video.working?)
    end
    can [:destroy], AnimeVideo do |anime_video|
      !@user.banned? && (anime_video.uploader == @user && anime_video.created_at > 1.week.ago)
    end
  end

  def moderator_ability
    can :manage, [Topic, AnimeNews, MangaNews, Review]
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

  def admin_ability
    can :manage, :all
  end
end
