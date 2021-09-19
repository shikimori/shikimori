class Abilities::ForumModerator
  include CanCan::Ability
  prepend Draper::CanCanCan

  MAXIMUM_COMMENTS_TO_DELETE = 250
  MAXIMUM_SUMMARIES_TO_DELETE = 25
  MAXIMUM_TOPIC_COMMENTS_TO_DELETE = 1_000

  def initialize _user # rubocop:disable MethodLength, AbcSize
    can :manage, Comment
    can :manage, Review

    can %i[edit update], Topic do |topic|
      !topic.generated? ||
        Abilities::User::GENERATED_USER_TOPICS.include?(topic.type)
    end
    can :manage, Topic do |topic|
      topic.comments_count < 2_000 && (
        !topic.generated? ||
          Abilities::User::GENERATED_USER_TOPICS.include?(topic.type)
      )
    end
    cannot :moderate, Topic

    can :close, Topic
    cannot :broadcast, Topic
    cannot :moderate, Topic
    cannot :promote, Topic

    can :manage, Ban
    cannot :destroy, Ban

    can :manage, AbuseRequest
    can %i[
      manage_censored_avatar_role
      manage_censored_profile_role
    ], User

    can :delete_all_comments, User do |user|
      Comment.where(user_id: user.id).where(is_summary: false).count < MAXIMUM_COMMENTS_TO_DELETE
    end
    can :delete_all_summaries, User do |user|
      Comment.where(user_id: user.id).where(is_summary: true).count < MAXIMUM_SUMMARIES_TO_DELETE
    end
    can :delete_all_topics, User do |user|
      Topic.where(user_id: user.id).sum(:comments_count) < MAXIMUM_TOPIC_COMMENTS_TO_DELETE
    end

    can %i[
      manage_not_trusted_abuse_reporter_role
    ], User
  end
end
