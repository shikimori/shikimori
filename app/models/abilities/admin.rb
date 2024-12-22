class Abilities::Admin
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user # rubocop:disable all
    can %i[
      upload_episode
      increment_episode
      rollback_episode
    ], Anime
    can %i[sync arbitrary_sync], [Anime, Manga, Person, Character] do |entry|
      entry.mal_id.present?
    end
    can :refresh_stats, [Anime, Manga]

    can %i[
      manage_super_moderator_role
      manage_news_super_moderator_role
      manage_cosplay_moderator_role
      manage_contest_moderator_role
    ], User

    can :manage, User
    can %i[access_list mass_ban], User
    cannot :reset_email, User, &:staff?

    can :manage, ListImport

    can :manage, Topic
    can :manage, Comment
    can :manage, Review
    can :manage, Message
    can :manage, Club
    can :manage, ClubPage
    can :manage, ClubImage
    can :manage, Poll
    can :manage, UserImage

    can :delete_all_comments, User
    can :delete_all_summaries, User
    can :delete_all_topics, User
    can :delete_all_critiques, User
    can :delete_all_reviews, User

    can :manage, Style
    can :manage, Version
    can :manage, Forum

    can :manage, OauthApplication

    can :destroy, Ban

    can :restart, Shikimori
  end
end
