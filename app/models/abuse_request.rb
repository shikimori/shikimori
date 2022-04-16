class AbuseRequest < ApplicationRecord
  include AASM
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
  validates :approver, presence: true, unless: :pending?

  attr_accessor :affected_ids # filled during state_machine transition

  scope :pending, -> {
    where state: :pending, kind: %i[offtopic summary convert_review]
  }
  scope :abuses, -> {
    where state: :pending, kind: %i[spoiler abuse]
  }

  aasm column: 'state', create_scopes: false do
    state Types::AbuseRequest::State[:pending], initial: true
    state Types::AbuseRequest::State[:accepted]
    state Types::AbuseRequest::State[:rejected]

    event :take do
      transitions to: Types::AbuseRequest::State[:accepted],
        from: Types::AbuseRequest::State[:pending]
    end
    event :reject do
      transitions to: Types::AbuseRequest::State[:rejected],
        from: Types::AbuseRequest::State[:pending]
    end

    # event :accept do
    #   transitions to: Types::AbuseRequest::State[:accepted],
    #     from: Types::AbuseRequest::State[:pending],
    #     after: :fill_approver
    # end
    # event :reject do
    #   transitions to: Types::AbuseRequest::State[:rejected],
    #     from: Types::AbuseRequest::State[:pending],
    #     after: :fill_approver,
    #     success: :handle_rejection
    # end
    # event :cancel do
    #   transitions to: Types::AbuseRequest::State[:pending],
    #     from: Types::AbuseRequest::State[:accepted]
    # end
  end

  # state_machine :state, initial: :pending do
  #   event :take do
  #     transition pending: :accepted
  #   end
  #
  #   event :reject do
  #     transition pending: :rejected
  #   end
  #
  #   before_transition pending: :accepted do |abuse_request, transition|
  #     abuse_request.approver = transition.args.first
  #     faye_token = transition.args.second
  #     assign_approver_option = transition.args.third
  #
  #     unless assign_approver_option == :skip
  #       faye = FayeService.new abuse_request.approver, faye_token
  #
  #       # process offtopic and summary requests only
  #       if faye.respond_to? abuse_request.kind
  #         abuse_request.affected_ids = faye.public_send(
  #           abuse_request.kind,
  #           abuse_request.comment || abuse_request.topic,
  #           abuse_request.value
  #         )
  #       end
  #     end
  #   end
  #
  #   before_transition pending: :rejected do |abuse_request, transition|
  #     abuse_request.approver = transition.args.first
  #   end
  # end

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
