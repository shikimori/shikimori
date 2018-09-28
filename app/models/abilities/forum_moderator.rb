class Abilities::ForumModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  def initialize _user
    can :manage, Comment
    can :manage, Topic do |topic|
      !topic.generated? ||
        Abilities::User::GENERATED_USER_TOPICS.include?(topic.type)
    end
    can :manage, Review
    can %i[edit update], Genre

    can :manage, Ban
    can :manage, AbuseRequest
    can %i[
      manage_censored_avatar_role
      manage_censored_profile_role
    ], User
  end
end
