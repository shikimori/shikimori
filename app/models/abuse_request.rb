class AbuseRequest < ActiveRecord::Base
  include PermissionsPolicy
  extend Enumerize

  MAXIMUM_REASON_SIZE = 255

  belongs_to :comment
  belongs_to :user
  belongs_to :approver, class_name: User.name, foreign_key: :approver_id

  enumerize :kind, in: [:offtopic, :review, :spoiler, :abuse], predicates: true

  validates :user, :comment, presence: true
  validates :reason, length: { maximum: MAXIMUM_REASON_SIZE }

  scope :pending, -> { where state: 'pending', kind: ['offtopic', 'review'] }
  scope :abuses, -> { where state: 'pending', kind: ['spoiler', 'abuse'] }

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
      if faye.respond_to? abuse_request.kind
        faye.send(abuse_request.kind, abuse_request.comment, abuse_request.value)
      else
        abuse_request.comment.mark abuse_request.kind, abuse_request.value
      end
    end

    before_transition pending: :rejected do |abuse_request, transition|
      abuse_request.approver = transition.args.first
    end
  end

  def reason= value
    if !value || value.size <= MAXIMUM_REASON_SIZE
      super
    else
      super value[0..MAXIMUM_REASON_SIZE-1]
    end
  end

  def punishable?
    abuse? || spoiler?
  end

  class << self
    # есть ли не прнятые запросы
    def has_changes?
      pending.count > 0
    end

    # есть ли не прнятые жалобы
    def has_abuses?
      abuses.count > 0
    end
  end
end
