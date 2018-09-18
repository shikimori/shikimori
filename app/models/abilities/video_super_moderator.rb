class Abilities::VideoSuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[index show none edit update], AnimeVideoAuthor

    can %i[
      manage_video_moderator_role
    ], User
  end
end
