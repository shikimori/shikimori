class Abilities::ForumModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MAXIMUM_COMMENTS_TO_DELETE = 250
  MAXIMUM_SUMMARIES_TO_DELETE = 25
  MAXIMUM_REVIEWS_TO_DELETE = 15
  MAXIMUM_TOPIC_COMMENTS_TO_DELETE = 1_000

  def initialize _user # rubocop:disable MethodLength, AbcSize
    can :manage, Comment
    can :manage, Review

    can %i[edit update full_update], Topic do |topic|
      !topic.generated? ||
        Abilities::User::GENERATED_USER_TOPICS.include?(topic.type)
    end
    can :manage, Topic do |topic|
      topic.comments_count < 2_000 && (
        !topic.generated? ||
          Abilities::User::GENERATED_USER_TOPICS.include?(topic.type)
      )
    end

    cannot :broadcast, Topic
    cannot :moderate, Topic
    cannot :pin, Topic

    can :manage, Ban
    cannot :destroy, Ban

    can :manage, AbuseRequest
    # forbid moderators to selfmoderate
    # can :manage, AbuseRequest do |abuse_request|
    #   abuse_request.comment&.user_id != user.id &&
    #     abuse_request.topic&.user_id != user.id
    # end

    can %i[
      manage_censored_avatar_role
      manage_censored_profile_role
      manage_censored_nickname_role
    ], User

    can :delete_all_comments, User do |model|
      Comment.where(user_id: model.id).count < MAXIMUM_COMMENTS_TO_DELETE
    end
    can :delete_all_summaries, User do |model|
      Comment.where(user_id: model.id).count < MAXIMUM_SUMMARIES_TO_DELETE
    end
    can :delete_all_reviews, User do |model|
      Review.where(user_id: model.id).count < MAXIMUM_REVIEWS_TO_DELETE
    end
    can :delete_all_topics, User do |model|
      Topic.where(user_id: model.id).sum(:comments_count) < MAXIMUM_TOPIC_COMMENTS_TO_DELETE
    end

    can %i[edit update], Collection
    can %i[edit update], Critique
    can %i[edit update], Article

    can %i[
      manage_not_trusted_abuse_reporter_role
    ], User
  end
end
