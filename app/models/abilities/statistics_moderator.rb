class Abilities::StatisticsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[
      manage_cheat_bot_role
      manage_completed_announced_animes_role
    ], User
    can :access_list, User
  end
end
