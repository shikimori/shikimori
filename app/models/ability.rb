# rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity, MethodLength, MissingCopEnableDirective
class Ability
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    define_abilities
    guest_restrictions unless user

    if user
      merge Abilities::User.new(user)

      if user.forum_moderator? || user.super_moderator? || user.admin?
        merge Abilities::ForumModerator.new(user)
      end

      if user.contest_moderator? || user.admin?
        merge Abilities::ContestModerator.new(user)
      end

      if user.review_moderator? || user.admin?
        merge Abilities::ReviewModerator.new(user)
      end

      if user.collection_moderator? || user.admin?
        merge Abilities::CollectionModerator.new(user)
      end

      if user.video_super_moderator? || user.admin?
        merge Abilities::VideoSuperModerator.new(user)
      end

      if user.video_moderator? || user.video_super_moderator? || user.admin?
        merge Abilities::VideoModerator.new(user)
      end

      if user.version_super_moderator? || user.admin?
        merge Abilities::VersionSuperModerator.new(user)
      end

      if user.version_moderator? || user.admin?
        merge Abilities::VersionModerator.new(user)
      end

      if user.version_fansub_moderator? || user.admin?
        merge Abilities::VersionFansubModerator.new(user)
      end

      if user.super_moderator? || user.admin?
        merge Abilities::SuperModerator.new(user)
      end

      merge Abilities::Admin.new(user) if user.admin?
    end

    guest_allowances
  end

  def define_abilities
    alias_action :current, :read, :users, :comments, :grid, to: :see_contest
    alias_action(
      :index, :show, :comments,
      :animes, :mangas, :ranobe, :characters, :members, :images,
      to: :see_club
    )
  end

  def guest_restrictions
    can :create, Message do |message|
      message.kind == MessageType::PRIVATE &&
        message.from_id == User::GUEST_ID &&
        message.to_id == User::MORR_ID
    end

    can :create, AnimeVideoReport do |report|
      report.user_id == User::GUEST_ID && (report.broken? || report.wrong?)
    end

    # can %i[new create], AnimeVideo, &:uploaded?
  end

  def guest_allowances
    can :access_list, User do |user|
      user.preferences.list_privacy_public?
    end

    can %i[read tooltip], Version
    can :tooltip, Genre
    can :see_contest, Contest
    can :see_club, Club
    can :read, ClubPage
    can :read, UserRate

    can %i[read preview], Style

    can :read, Review
    can :read, Topic
    can :read, Collection
    can :read, OauthApplication
    can :read, Ban
    can :read, AbuseRequest
    can :read, UserRateLog
    can :read, Version
  end
end
