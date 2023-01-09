class Abilities::TrustedNewsmaker
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize user
    can :accept, Topics::NewsTopic do |news|
      news.user_id == user.id
    end
  end
end
