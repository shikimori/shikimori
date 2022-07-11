class Abilities::ArticleModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  ARTICLE_MODERATOR_ACTIONS = %i[edit update destroy]

  def initialize _user
    can :manage, Article # needed to accept or reject
    can ARTICLE_MODERATOR_ACTIONS, Topics::EntryTopics::ArticleTopic
  end
end
