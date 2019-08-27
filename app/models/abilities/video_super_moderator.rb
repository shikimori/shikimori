class Abilities::VideoSuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :rollback_episode, Anime
    can %i[index show none edit update], AnimeVideoAuthor

    can %i[
      manage_video_moderator_role
      manage_trusted_video_uploader_role
      manage_not_trusted_video_uploader_role
      manage_trusted_video_changer_role
      manage_censored_avatar_role
      manage_censored_profile_role
      manage_trusted_fansub_changer_role
    ], User

    can :destroy, AnimeVideo
  end
end
