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

  belongs_to :comment
  belongs_to :user
  belongs_to :approver,
    class_name: 'User',
    foreign_key: :approver_id,
    optional: true

  enumerize :kind, in: %i[offtopic summary spoiler abuse], predicates: true

  validates :user, :comment, presence: true
  validates :reason, length: { maximum: 4096 }

  scope :pending, -> { where state: 'pending', kind: %w[offtopic summary] }
  scope :abuses, -> { where state: 'pending', kind: %w[spoiler abuse] }

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
      faye = FayeService.new(abuse_request.approver, '')

      # process offtopic and summary requests only
      if faye.respond_to? abuse_request.kind
        faye.public_send(
          abuse_request.kind,
          abuse_request.comment,
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
end
