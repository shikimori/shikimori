class Abilities::VideoSuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :upload_episode, Anime
    can :increment_episode, Anime
    can :rollback_episode, Anime

    can :manage_fansub_authors, Anime
  end
end
