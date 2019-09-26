class Abilities::StatisticsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[
      manage_cheat_bot_role
    ], User
  end
end
