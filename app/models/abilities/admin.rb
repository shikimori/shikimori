class Abilities::Admin
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user # rubocop:disable all
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

    can :manage, Topic
    can :manage, Comment
    can :manage, Message
    can :manage, Club
    can :manage, ClubPage
    can :manage, ClubImage

    can :delete_all_comments, User
    can :delete_all_topics, User
    can :delete_all_reviews, User

    can :manage, Style
    can :manage, Version
    can :manage, Forum

    can :manage, OauthApplication

    can :destroy, Ban
  end
end
