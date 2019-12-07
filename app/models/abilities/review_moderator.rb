class Abilities::ReviewModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Review
    can :delete_all_reviews, User
  end
end
