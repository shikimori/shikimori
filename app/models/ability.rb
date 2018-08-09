# https://github.com/rilian/devise-doorkeeper-cancan-api-example/blob/master/spec/abilities/admin_spec.rb
class Ability
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    define_abilities
    guest_restrictions

    if user
      merge Abilities::User.new(user)
      merge Abilities::ForumModerator.new(user) if user.forum_moderator?
      merge Abilities::ContestModerator.new(user) if user.contest_moderator?
      merge Abilities::ReviewModerator.new(user) if user.review_moderator?
      merge Abilities::VideoModerator.new(user) if user.video_moderator?
      if user.video_super_moderator?
        merge Abilities::VideoSuperModerator.new(user)
      end
      merge Abilities::VersionModerator.new(user) if user.version_moderator?
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
    can :access_list, User do |user|
      user.preferences.list_privacy_public?
    end

    can :create, Message do |message|
      message.kind == MessageType::Private &&
        message.from_id == User::GUEST_ID &&
        message.to_id == User::MORR_ID
    end

    can :create, AnimeVideoReport do |report|
      report.user_id == User::GUEST_ID && (report.broken? || report.wrong?)
    end
    can %i[new create], AnimeVideo, &:uploaded?

    can :create, Version do |version|
      version.user_id == User::GUEST_ID && (
        version.item_diff.keys & (
          version.item_type.constantize::SIGNIFICANT_MAJOR_FIELDS +
          version.item_type.constantize::SIGNIFICANT_MINOR_FIELDS
        )
      ).none?
    end
    cannot :major_change, Version
  end

  def guest_allowances
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
  end
end
