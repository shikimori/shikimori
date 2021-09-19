class Abilities::Admin
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user # rubocop:disable all
    can :upload_episode, Anime
    can :increment_episode, Anime
    can :rollback_episode, Anime
    can :sync, [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end

    can %i[
      manage_super_moderator_role
      manage_news_super_moderator_role
      manage_cosplay_moderator_role
      manage_contest_moderator_role
    ], User

    can :manage, User
    can :access_list, User
    can :manage, ListImport

    can :manage, Topic
    can :manage, Comment
    can :manage, Review
    can :manage, Message
    can :manage, Club
    can :manage, ClubPage
    can :manage, ClubImage
    can :manage, Poll

    can :delete_all_comments, User
    can :delete_all_summaries, User
    can :delete_all_topics, User
    can :delete_all_critiques, User

    can :manage, Style
    can :manage, Version
    can :manage, Forum

    can :manage, OauthApplication

    can :destroy, Ban
  end
end
