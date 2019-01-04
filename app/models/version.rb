class Version < ApplicationRecord
  include AntispamConcern

  antispam(
    per_day: 15,
    scope: -> { where.not item_type: AnimeVideo.name },
    enable_if: -> { item_type != AnimeVideo.name },
    disable_if: -> { user.version_moderator? || user.trusted_version_changer? },
    user_id_key: :user_id
  )
  antispam(
    per_day: 50,
    scope: -> { where item_type: AnimeVideo.name },
    enable_if: -> { item_type == AnimeVideo.name },
    disable_if: -> {
      user.video_moderator? || user.trusted_video_uploader? || user.trusted_video_changer?
    },
    user_id_key: :user_id
  )

  MAXIMUM_REASON_SIZE = 255

  belongs_to :user
  belongs_to :moderator, class_name: User.name, optional: true
  # optional item becase it can be deleted later and we don't need this version to fail on validation
  belongs_to :item, polymorphic: true, touch: true, optional: true

  validates :item_diff, presence: true
  validates :item, presence: true, if: :new_record?
  validates :reason, length: { maximum: MAXIMUM_REASON_SIZE }

  scope :pending_content, -> {
    where(state: :pending).where.not(item_type: AnimeVideo.name)
  }
  scope :pending_videos, -> {
    where(state: :pending).where(item_type: AnimeVideo.name)
  }

  state_machine :state, initial: :pending do
    state :accepted
    state :auto_accepted
    state :rejected

    state :taken
    state :deleted

    event(:accept) { transition pending: :accepted }
    event(:auto_accept) do
      transition pending: :auto_accepted, if: :auto_acceptable?
    end
    event(:take) { transition pending: :taken }
    event(:reject) { transition %i[pending auto_accepted] => :rejected }
    event(:to_deleted) { transition pending: :deleted, if: :deleteable? }

    event(:accept_taken) { transition taken: :accepted, if: :takeable? }
    event(:take_accepted) { transition accepted: :taken, if: :takeable? }

    before_transition(
      pending: %i[accepted auto_accepted taken]
    ) do |version, transition|
      version.apply_changes || raise(
        StateMachine::InvalidTransition.new(
          version,
          transition.machine,
          transition.event
        )
      )
    end

    before_transition auto_accepted: :rejected do |version, transition|
      version.rollback_changes || raise(
        StateMachine::InvalidTransition.new(
          version,
          transition.machine,
          transition.event
        )
      )
    end

    before_transition(
      %i[pending auto_accepted] => %i[accepted taken rejected deleted]
    ) do |version, transition|
      version.update moderator: transition.args.first if transition.args.first
    end

    after_transition pending: %i[accepted taken] do |version, _transition|
      version.fix_state if version.respond_to? :fix_state
      version.notify_acceptance
    end

    after_transition(
      %i[pending auto_accepted] => %i[rejected]
    ) do |version, transition|
      version.notify_rejection transition.args.second
    end

    after_transition pending: :deleted do |version, _transition|
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
    attributes = item_diff.each_with_object({}) do |(field, changes), memo|
      memo[field] = changes.first
    end

    item.update attributes
  end

  def current_value field
    item.send field
  rescue NoMethodError
  end

  def notify_acceptance
    unless user_id == moderator_id
      Message.create_wo_antispam!(
        from_id: moderator_id,
        to_id: user_id,
        kind: MessageType::VERSION_ACCEPTED,
        linked: self
      )
    end
  end

  def notify_rejection reason
    unless user_id == moderator_id
      Message.create_wo_antispam!(
        from_id: moderator_id,
        to_id: user_id,
        kind: MessageType::VERSION_REJECTED,
        linked: self,
        body: reason
      )
    end
  end

  def takeable?
    false
  end

  def deleteable?
    true
  end

private

  def apply_change field, changes
    changes[0] = current_value field
    item.send "#{field}=", truncate_value(field, changes.second)

    add_desynced field

    item.save && save
  end

  def add_desynced field
    if item.respond_to?(:desynced) && item.class::DESYNCABLE.include?(field)
      item.desynced << field unless item.desynced.include?(field)
    end
  end

  def truncate_value field, value
    if item.class.columns_hash[field]&.limit && value.is_a?(String)
      value[0..item.class.columns_hash[field].limit - 1]
    else
      value
    end
  end

  def auto_acceptable?
    item_type != AnimeVideo.name || user.video_moderator? || user.trusted_video_changer?
  end
end
