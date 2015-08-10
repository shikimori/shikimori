class Version < ActiveRecord::Base
  MAXIMUM_REASON_SIZE = 255

  belongs_to :user
  belongs_to :moderator, class_name: User
  belongs_to :item, polymorphic: true

  validates :item, :item_diff, presence: true
  validates :reason, length: { maximum: MAXIMUM_REASON_SIZE }

  state_machine :state, initial: :pending do
    state :accepted
    state :auto_accepted
    state :rejected

    state :taken
    state :deleted

    event(:accept) { transition :pending => :accepted }
    event(:auto_accept) { transition :pending => :auto_accepted }
    event(:take) { transition :pending => :taken }
    event(:reject) { transition [:pending, :auto_accepted] => :rejected }
    event(:to_deleted) { transition :pending => :deleted }

    before_transition :pending => [:accepted, :auto_accepted, :taken] do |version, transition|
      version.apply_changes ||
        raise(StateMachine::InvalidTransition.new version, transition.machine, transition.event)
    end

    before_transition :auto_accepted => :rejected do |version, transition|
      version.rollback_changes ||
        raise(StateMachine::InvalidTransition.new version, transition.machine, transition.event)
    end

    before_transition [:pending, :auto_accepted] => [:accepted, :taken, :rejected, :deleted] do |version, transition|
      version.update moderator: transition.args.first if transition.args.first
    end

    after_transition :pending => [:accepted, :taken] do |version, transition|
      version.notify_acceptance
    end

    after_transition [:pending, :auto_accepted] => [:rejected] do |version, transition|
      version.notify_rejection transition.args.second
    end
  end

  class << self
    def pending_count
      Version.where(state: :pending).size
    end

    def has_changes?
      pending_count > 0
    end
  end

  def reason= value
    if !value || value.size <= MAXIMUM_REASON_SIZE
      super
    else
      super value[0..MAXIMUM_REASON_SIZE-1]
    end
  end

  def apply_changes
    attributes = item_diff.each_with_object({}) do |(field,changes), memo|
      memo[field] = changes.second
      changes[0] = current_value field
    end

    if item.update attributes
      save
    else
      false
    end
  end

  def rollback_changes
    attributes = item_diff.each_with_object({}) do |(field,changes), memo|
      memo[field] = changes.first
    end

    item.update attributes
  end

  def current_value field
    item.send field
  end

  def notify_acceptance
    Message.create_wo_antispam!(
      from_id: moderator_id,
      to_id: user_id,
      kind: MessageType::VersionAccepted,
      linked: self
    ) unless user_id == moderator_id
  end

  def notify_rejection reason
    Message.create_wo_antispam!(
      from_id: moderator_id,
      to_id: user_id,
      kind: MessageType::VersionRejected,
      linked: self,
      body: reason
    ) unless user_id == moderator_id
  end
end
