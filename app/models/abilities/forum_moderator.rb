class Abilities::ForumModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MINIMUM_COMMENTS = 1_000

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

    can :delete_all_comments, User do |user|
      Comment.where(user_id: user.id).count < MINIMUM_COMMENTS
    end

    can :delete_all_topics, User do |user|
      Topic.where(user_id: user.id).sum(:comments_count) < MINIMUM_COMMENTS
    end

    can :delete_all_reviews, User
  end
end
