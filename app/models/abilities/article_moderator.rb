class Abilities::ArticleModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Article
  end
end
