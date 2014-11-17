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
      admin_ability if @user.admin?
    end
  end

  def define_abilities
    #alias_action :read, to: :see_profile
    alias_action :current, :read, :users, :comments, :grid, to: :see_contest
    alias_action :read, :comments, :animes, :mangas, :characters, :members, :images, to: :see_club
  end

  def guest_ability
    can :see_list, User do |user|
      user.preferences.profile_privacy_public?
    end
    can :see_contest, Contest
    can :see_club, Group
  end

  def user_ability
    can :manage, UserRate, user_id: @user.id
    can [:cleanup, :reset], UserRate

    can :destroy, Image do |image|
      image.uploader_id == @user.id || can?(:edit, image.owner)
    end

    can :see_list, User do |user|
      if user == @user || user.preferences.profile_privacy_public? || user.preferences.profile_privacy_users?
        true
      elsif user.preferences.profile_privacy_friends? && user.friended?(@user)
        true
      else
        false
      end
    end
    can [:edit, :update], User do |user|
      user == @user || @user.admin?
    end

    can [:new], Group
    can [:create, :update], Group do |group|
      group.owner?(@user) || group.admin?(@user)
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
        group.owner?(@user) || group.admin?(@user)

      elsif group.upload_policy == GroupUploadPolicy::ByMembers
        group.joined?(@user) && group.display_images

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
    #can :create, GroupInvite do |group_invite|
      #can? :invite, group_invite.group
    #end

    can :manage, Device, user_id: @user.id

    can [:new, :create], [Topic, AnimeNews, MangaNews] do |topic|
      topic.user_id == @user.id
    end
    can [:update], [Topic, AnimeNews, MangaNews] do |topic|
      topic.user_id == @user.id && topic.created_at + 3.months > Time.zone.now
    end
    can [:destroy], [Topic, AnimeNews, MangaNews] do |topic|
      topic.user_id == @user.id && topic.created_at + 4.hours > Time.zone.now
    end
  end

  def moderator_ability
    can :manage, [Topic, AnimeNews, MangaNews]
  end

  def contests_moderator_ability
    can :manage, Contest
    cannot :destroy, Contest
  end

  def admin_ability
    can :manage, :all
  end
end
