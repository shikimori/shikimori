class Abilities::ArticleModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  ARTICLES_MODERATOR_ACTIONS = %i[edit update destroy]

  def initialize _user
    can :manage, Article
    can ARTICLES_MODERATOR_ACTIONS, Topics::EntryTopics::ArticleTopic
  end
end
