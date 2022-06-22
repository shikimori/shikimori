class Abilities::NewsSuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    roles_abilities

    can :manage, Ban
    can :access_list, User

    can :manage, Club
    can :manage, ClubPage
    can :manage, ClubImage
  end

  def roles_abilities
    can %i[
      manage_critique_moderator_role
      manage_news_moderator_role
      manage_article_moderator_role
      manage_collection_moderator_role
      manage_trusted_newsmaker_role

      manage_censored_avatar_role
      manage_censored_profile_role
      manage_cheat_bot_role
      manage_ignored_in_achievement_statistics_role
    ], User
  end
end
