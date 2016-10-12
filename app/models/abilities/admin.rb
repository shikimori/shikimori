class Abilities::Admin
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :manage, :all
  end
end
