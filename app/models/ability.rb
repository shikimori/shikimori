class Ability
  include CanCan::Ability

  def initialize user
    define_abilities

    @user = user
    guest_ability

    if @user
      user_ability
      contests_moderator_ability if @user.contests_moderator?
      admin_ability if @user.admin?
    end
  end

  def define_abilities
    alias_action :current, :read, :users, :comments, :grid, to: :read_contest
    alias_action :read, :comments, :animes, :mangas, :members, :images, to: :read_group
  end

  def guest_ability
    can :read_contest, Contest
    can :read_group, Group
  end

  def user_ability
    can :manage, UserRate, user_id: @user.id
    can [:cleanup, :reset], UserRate

    can :join, Group do |group|
      !group.has_member?(@user) && (
        can?(:manage, group) || (!group.banned?(@user) && group.free_join?)
      )
    end
    can :invite, Group do |group|
      group.has_member?(@user) && (
        group.free_join? ||
        (group.admin_invite_join? && (group.has_admin?(@user) || group.has_owner?(@user))) ||
        (group.owner_invite_join? && group.has_owner?(@user))
      )
    end
    can :leave, Group do |group|
      group.has_member? @user
    end
    can :update, Group do |group|
      group.has_owner?(@user) || group.has_admin?(@user)
    end

    can :create, GroupRole do |group_role|
      group_role.user_id == @user.id && can?(:join, group_role.group)
    end
    can :destroy, GroupRole do |group_role|
      group_role.user_id == @user.id
    end

    can [:accept, :reject], GroupInvite, dst_id: @user.id
    can :create, GroupInvite do |group_invite|
      group_invite.src_id == @user.id && group_invite.group.has_member?(@user)
    end
    #can :create, GroupInvite do |group_invite|
      #can? :invite, group_invite.group
    #end

    can :manage, Device, user_id: @user.id
  end

  def contests_moderator_ability
    can :manage, Contest
    cannot :destroy, Contest
  end

  def admin_ability
    can :manage, :all
  end

end
