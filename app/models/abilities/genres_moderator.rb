class Abilities::GenresModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :update, Genre
    can :update, GenreV2
    can :update, Studio
    can :update, Publisher
  end
end
