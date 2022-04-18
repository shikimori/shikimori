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

    event :accept do
      transitions to: Types::AbuseRequest::State[:accepted],
        from: Types::AbuseRequest::State[:pending],
        after: :assign_approver,
        success: :postprocess_acception
    end
    event :reject do
      transitions to: Types::AbuseRequest::State[:rejected],
        from: Types::AbuseRequest::State[:pending],
        after: :assign_approver
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

private

  def assign_approver approver:, **_args
    self.approver = approver
  end

  def postprocess_acception approver:, is_process_in_faye: true, faye_token: nil
    return unless is_process_in_faye

    faye = FayeService.new approver, faye_token

    # process offtopic and summary requests only
    if faye.respond_to? kind
      self.affected_ids = faye.public_send kind, comment || topic, value
    end
  end
end
