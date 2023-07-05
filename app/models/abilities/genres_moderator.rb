class Abilities::GenresModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Genre
    can :manage, GenreV2
  end
end
