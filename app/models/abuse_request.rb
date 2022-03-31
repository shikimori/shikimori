class AbuseRequest < ApplicationRecord
  include AntispamConcern

  antispam(
    per_day: 25,
    disable_if: -> { user.forum_moderator? },
    user_id_key: :user_id
  )
  antispam(
    per_day: 3,
    disable_if: -> { !user.not_trusted_abuse_reporter? },
    user_id_key: :user_id
  )

  belongs_to :comment, optional: true
  belongs_to :topic, optional: true
  belongs_to :user
  belongs_to :approver,
    class_name: 'User',
    optional: true

  enumerize :kind,
    in: Types::AbuseRequest::Kind.values,
    predicates: true

  validates :reason, length: { maximum: 4096 }
  validates :comment_id, exclusive_arc: %i[topic_id]

  attr_accessor :affected_ids # filled during state_machine transition

  scope :pending, -> {
    where state: :pending, kind: %i[offtopic summary convert_review]
  }
  scope :abuses, -> {
    where state: :pending, kind: %i[spoiler abuse]
  }

  state_machine :state, initial: :pending do
    state :pending
    state :accepted do
      validates :approver, presence: true
    end
    state :rejected do
      validates :approver, presence: true
    end

    event :take do
      transition pending: :accepted
    end

    event :reject do
      transition pending: :rejected
    end

    before_transition pending: :accepted do |abuse_request, transition|
      abuse_request.approver = transition.args.first
      faye_token = transition.args.second

      faye = FayeService.new abuse_request.approver, faye_token

      # process offtopic and summary requests only
      if faye.respond_to? abuse_request.kind
        abuse_request.affected_ids = faye.public_send(
          abuse_request.kind,
          abuse_request.comment || abuse_request.topic,
          abuse_request.value
        )
      end
    end

    before_transition pending: :rejected do |abuse_request, transition|
      abuse_request.approver = transition.args.first
    end
  end

  def punishable?
    abuse? || spoiler?
  end

  def target
    comment || topic
  end

  def target_type
    if comment_id
      Comment.name
    elsif topic_id
      Topic.name
    end
  end
end
