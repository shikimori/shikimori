class Abilities::VideoModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, AnimeVideoReport
    cannot :destroy, AnimeVideoReport

    can %i[new create edit update], AnimeVideo do |anime_video|
      !anime_video.banned_hosting? && !anime_video.copyrighted?
    end
    can :manage, Version do |version|
      version.item_type == AnimeVideo.name
    end
    can :minor_change, Version
  end
end
