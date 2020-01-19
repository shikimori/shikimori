class Abilities::TrustedVersionChanger
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[create], Version do |version|
      version.user_id == @user.id &&
        !version.is_a?(Versions::RoleVersion)
    end

    can :restricted_update, Version

    can :auto_accept, Version do |version|
      can? :create, version
    end
  end
end
