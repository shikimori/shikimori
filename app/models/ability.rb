class Ability
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    define_abilities
    guest_restrictions

    if user
      merge Abilities::User.new(user)
      merge Abilities::Moderator.new(user) if user.moderator?
      merge Abilities::ContestsModerator.new(user) if user.contests_moderator?
      merge Abilities::ReviewsModerator.new(user) if user.reviews_moderator?
      merge Abilities::VideoModerator.new(user) if user.video_moderator?
      merge Abilities::VersionsModerator.new(user) if user.versions_moderator?
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
        message.from_id == User::GUEST_ID && message.to_id == User::ADMINS.first
    end

    can :create, AnimeVideoReport do |report|
      report.user_id == User::GUEST_ID && (report.broken? || report.wrong?)
    end
    can %i[new create], AnimeVideo do |anime_video|
      anime_video.uploaded?
    end

    can :create, Version do |version|
      version.user_id == User::GUEST_ID && (
        version.item_diff.keys & version.item_type.constantize::SIGNIFICANT_FIELDS
      ).none?
    end
    cannot :significant_change, Version
  end

  def guest_allowances
    can %i[read tooltip], Version
    can :tooltip, Genre
    can :see_contest, Contest
    can :see_club, Club
    can :read, ClubPage

    can %i[read preview], Style

    can :read, Review
    can :read, Topic
    can :read, Collection
  end
end
