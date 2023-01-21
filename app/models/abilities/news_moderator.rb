class Abilities::NewsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  NEWS_MODERATOR_ACTIONS = %i[edit update destroy moderate pin close accept]

  def initialize _user
    can NEWS_MODERATOR_ACTIONS, Topics::NewsTopic
  end
end
