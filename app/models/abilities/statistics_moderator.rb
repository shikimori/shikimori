class Abilities::StatisticsModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[
      manage_ignored_in_achievement_statistics_role
    ], User
    can :access_list, User
  end
end
