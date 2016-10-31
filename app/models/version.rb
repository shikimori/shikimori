class Version < ActiveRecord::Base
  MAXIMUM_REASON_SIZE = 255

  ABUSE_USER_IDS = [91184]

  belongs_to :user
  belongs_to :moderator, class_name: User
  belongs_to :item, polymorphic: true, touch: true

  validates :item, :item_diff, presence: true
  validates :reason, length: { maximum: MAXIMUM_REASON_SIZE }

  scope :pending_content, lambda {
    where(state: :pending).where.not(item_type: AnimeVideo.name)
  }
  scope :pending_videos, lambda {
    where(state: :pending).where(item_type: AnimeVideo.name)
  }

  state_machine :state, initial: :pending do
    state :accepted
    state :auto_accepted
    state :rejected

    state :taken
    state :deleted

    event(:accept) { transition :pending => :accepted }
    event(:auto_accept) { transition :pending => :auto_accepted, if: :auto_acceptable? }
    event(:take) { transition :pending => :taken }
    event(:reject) { transition [:pending, :auto_accepted] => :rejected }
    event(:to_deleted) { transition :pending => :deleted }

    event(:accept_taken) { transition :taken => :accepted, if: :takeable? }
    event(:take_accepted) { transition :accepted => :taken, if: :takeable? }

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
      version.fix_state if version.respond_to? :fix_state
      version.notify_acceptance
    end

    after_transition [:pending, :auto_accepted] => [:rejected] do |version, transition|
      version.notify_rejection transition.args.second
    end

    after_transition :pending => :deleted do |version, transition|
      version.cleanup if version.respond_to? :cleanup
    end
  end

  def reason= value
    if !value || value.size <= MAXIMUM_REASON_SIZE
      super
    else
      super value[0..MAXIMUM_REASON_SIZE - 1]
    end
  end

  def apply_changes
    item.class.transaction do
      item_diff.each { |(field, changes)| apply_change field, changes }
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
  rescue NoMethodError
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

  def takeable?
    false
  end

private

  def apply_change field, changes
    changes[0] = current_value field
    item.send "#{field}=", truncate_value(field, changes.second)

    if item.respond_to?(:desynced) && item.class::DESYNCABLE.include?(field)
      item.desynced << field unless item.desynced.include?(field)
    end

    item.save && save
  end

  def truncate_value field, value
    if item.class.columns_hash[field]&.limit && value.is_a?(String)
      value[0..item.class.columns_hash[field].limit - 1]
    else
      value
    end
  end

  def auto_acceptable?
    !ABUSE_USER_IDS.include?(user_id)# &&
      # (item_type != AnimeVideo.name || user.video_moderator?)
  end
end
