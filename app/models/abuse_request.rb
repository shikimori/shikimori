class AbuseRequest < ActiveRecord::Base
  include PermissionsPolicy
  extend Enumerize

  belongs_to :comment
  belongs_to :user
  belongs_to :approver, class_name: User.name, foreign_key: :approver_id

  enumerize :kind, in: [:offtopic, :review, :spoiler, :abuse], predicates: true

  validates :user, presence: true
  validates :comment, presence: true

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
      abuse_request.comment.mark abuse_request.kind, abuse_request.value
    end

    before_transition pending: :rejected do |abuse_request, transition|
      abuse_request.approver = transition.args.first
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
