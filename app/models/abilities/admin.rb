class Abilities::Admin
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :rollback_episode, Anime
    can %i[
      manage_super_moderator_role
      manage_video_super_moderator_role
      manage_cosplay_moderator_role
      manage_contest_moderator_role
      manage_api_video_uploader_role
    ], User

    can :manage, User
    can :manage, ListImport

    can :manage, Message
    can :manage, Club
    can :manage, ClubPage

    cannot :delete_all_comments, User
    cannot :delete_all_topics, User
    cannot :delete_all_reviews, User

    can :manage, Style
    can :manage, Version
    can :manage, Forum
  end
end
