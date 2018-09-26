class Abilities::VideoSuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[index show none edit update], AnimeVideoAuthor

    can %i[
      manage_video_moderator_role
      manage_trusted_video_uploader_role
      manage_not_trusted_video_uploader_role
      manage_trusted_video_changer_role
    ], User
  end
end
