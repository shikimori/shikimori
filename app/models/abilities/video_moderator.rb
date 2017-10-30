class Abilities::VideoModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, AnimeVideoReport
    can %i[new create edit update], AnimeVideo do |anime_video|
      !anime_video.banned? && !anime_video.copyrighted?
    end
    can :manage, Version do |version|
      version.item_type == AnimeVideo.name
    end
  end
end
