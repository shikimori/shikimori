class Version < ApplicationRecord # rubocop:disable ClassLength
  include AASM
  include AntispamConcern

  antispam(
    per_day: 50,
    disable_if: -> { item_diff['description_ru'].present? || user.staff? },
    scope: -> { where "(item_diff->>'description_ru') is null" },
    user_id_key: :user_id
  )
  antispam(
    per_day: 10,
    disable_if: -> { item_diff['description_ru'].blank? || user.staff? },
    scope: -> { where "(item_diff->>'description_ru') is not null" },
    user_id_key: :user_id
  )

  belongs_to :user, touch: Rails.env.test? ? false : :activity_at
  belongs_to :moderator, class_name: 'User', optional: true
  # optional item becase it can be deleted later and we don't need this version to fail on validation
  belongs_to :item, polymorphic: true, touch: true, optional: true
  belongs_to :associated, polymorphic: true, touch: true, optional: true

  validates :item_diff, presence: true
  validates :item, presence: true, if: :new_record?

  scope :pending, -> { where state: :pending }

  aasm column: 'state' do # rubocop:disable BlockLength
    state Types::Version::State[:pending], initial: true
    state Types::Version::State[:accepted]
    state Types::Version::State[:auto_accepted]
    state Types::Version::State[:rejected]
    state Types::Version::State[:taken]
    state Types::Version::State[:deleted]

    event :accept do
      transitions(
        from: Types::Version::State[:pending],
        to: Types::Version::State[:accepted]
      ) do
        after :apply_version
        after :assign_moderator
        success :notify_acceptance
      end
      after :reevaluate_state
    end
    event :auto_accept do
      transitions(
        from: Types::Version::State[:pending],
        to: Types::Version::State[:auto_accepted],
        unless: :takeable?
      ) do
        after :apply_version
        after :assign_moderator
      end
      after :reevaluate_state
    end
    event :take do
      transitions(
        from: Types::Version::State[:pending],
        to: Types::Version::State[:taken]
      ) do
        after :apply_version
        after :assign_moderator
        success :notify_acceptance
      end
      after :reevaluate_state
    end
    event :reject do
      transitions(
        from: Types::Version::State[:pending],
        to: Types::Version::State[:rejected]
      ) do
        after :reject_version
        after :assign_moderator
        success :notify_rejection
      end
      transitions(
        from: Types::Version::State[:auto_accepted],
        to: Types::Version::State[:rejected]
      ) do
        after :rollback_version
        after :assign_moderator
        success :notify_rejection
      end
    end
    event :to_deleted do
      transitions(
        from: Types::Version::State[:pending],
        to: Types::Version::State[:deleted],
        if: :deleteable?,
        after: :assign_moderator
      )
      after :sweep_deleted
    end
    event :accept_taken do
      transitions(
        from: Types::Version::State[:taken],
        to: Types::Version::State[:accepted],
        if: -> { takeable? || optionally_takeable? }
      )
    end
    event :take_accepted do
      transitions(
        from: Types::Version::State[:accepted],
        to: Types::Version::State[:taken],
        if: -> { takeable? || optionally_takeable? }
      )
    end
  end

  def apply_changes
    item.class.transaction do
      item_diff
        .sort_by { |(field, _changes)| field == 'desynced' ? 1 : 0 }
        .all? { |(field, changes)| apply_change field, changes }
    end
  end

  def reject_changes
    true
  end

  def rollback_changes
    item.update item_diff.transform_values(&:first)
  end

  def current_value field
    item.send field
  rescue NoMethodError
  end

  def notify_acceptance **_args
    unless user_id == moderator_id
      Message.create_wo_antispam!(
        from_id: moderator_id,
        to_id: user_id,
        kind: MessageType::VERSION_ACCEPTED,
        linked: self
      )
    end
  end

  def notify_rejection reason:, **_args
    return if user_id == moderator_id

    Message.create_wo_antispam!(
      from_id: moderator_id,
      to_id: user_id,
      kind: MessageType::VERSION_REJECTED,
      linked: self,
      body: reason
    )
  end

  def takeable? **_args
    false
  end

  def optionally_takeable?
    false
  end

  def deleteable?
    true
  end

private

  def apply_version **_args
    item.class.transaction { apply_changes } ||
      raise(StateMachineRollbackError.new(self, :apply))
  end

  def reject_version **_args
    item.class.transaction { reject_changes } ||
      raise(StateMachineRollbackError.new(self, :reject))
  end

  def rollback_version **_args
    item.class.transaction { rollback_changes } ||
      raise(StateMachineRollbackError.new(self, :rollback))
  end

  def assign_moderator moderator: user, **_args
    self.moderator = moderator
  end

  def reevaluate_state **_args
    # implemented in inherited classes
  end

  # sweep resources of deleted version
  def sweep_deleted **_args
    # implemented in inherited classes
  end

  def apply_change field, changes
    changes[0] = current_value field
    item.send "#{field}=", truncate_value(field, changes.second)

    add_desynced field

    item.save && save
  end

  def add_desynced field
    if item.respond_to?(:desynced) &&
        item.class::DESYNCABLE.include?(field) &&
        item.desynced.exclude?(field)
      item.desynced << field
    end
  end

  def truncate_value field, value
    if item.class.columns_hash[field]&.limit && value.is_a?(String)
      value[0..item.class.columns_hash[field].limit - 1]
    else
      value
    end
  end
end
