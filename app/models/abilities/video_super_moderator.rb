class Abilities::VideoSuperModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can %i[index show none edit update], AnimeVideoAuthor
  end
end
