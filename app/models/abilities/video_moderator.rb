class Abilities::VideoModerator
  include CanCan::Ability

  def initialize user
    can :manage, AnimeVideoReport
    can [:new, :create, :edit, :update], AnimeVideo do |anime_video|
      !user.banned? && !anime_video.banned? && !anime_video.copyrighted?
    end
    can :manage, Version do |version|
      version.item_type == AnimeVideo.name
    end

    if user.id == User::BAKSIII_ID
      can [:index, :edit, :update], AnimeVideoAuthor
    end
  end
end
