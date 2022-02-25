class Abilities::NewsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[edit update destroy], Topics::NewsTopic
    can :moderate, Topics::NewsTopic
    can :pin, Topics::NewsTopic
    can :close, Topics::NewsTopic
  end
end
