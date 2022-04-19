class Version < ApplicationRecord
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
        after :apply_transaction
        after :assign_moderator
        after :notify_acceptance
      end
    end
    event :auto_accept do
      transitions(
        from: Types::Version::State[:pending],
        to: Types::Version::State[:auto_accepted],
        unless: :takeable?
      ) do
        after :apply_transaction
        after :assign_moderator
      end
    end
    event :reject do
      transitions(
        from: [
          Types::Version::State[:pending],
          Types::Version::State[:auto_accepted]
        ],
        to: Types::Version::State[:rejected]
        # after: :assign_moderator
      )
    end
    event :take do
      transitions(
        from: Types::Version::State[:pending],
        to: Types::Version::State[:taken]
      ) do
        after :apply_transaction
        after :assign_moderator
        after :notify_acceptance
      end
    end
    event :to_deleted do
      transitions(
        from: Types::Version::State[:pending],
        to: Types::Version::State[:deleted],
        if: :deleteable?
      )
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

  #   before_transition(
  #     pending: %i[accepted auto_accepted taken]
  #   ) do |version, transition|
  #     version.apply_changes || raise(
  #       StateMachine::InvalidTransition.new(
  #         version,
  #         transition.machine,
  #         transition.event
  #       )
  #     )
  #     version.update moderator: version.user if transition.event
  #   end
  #
  # #   before_transition pending: %i[auto_accepted] do |version, _transition|
  # #     version.moderator = version.user
  # #   end
  #
  #   before_transition pending: :rejected do |version, transition|
  #     version.reject_changes || raise(
  #       StateMachine::InvalidTransition.new(
  #         version,
  #         transition.machine,
  #         transition.event
  #       )
  #     )
  #   end
  #
  #   before_transition auto_accepted: :rejected do |version, transition|
  #     version.rollback_changes || raise(
  #       StateMachine::InvalidTransition.new(
  #         version,
  #         transition.machine,
  #         transition.event
  #       )
  #     )
  #   end
  #
  #   before_transition(
  #     %i[pending auto_accepted] => %i[rejected deleted]
  #   ) do |version, transition|
  #     version.update moderator: transition.args.first if transition.args.first
  #   end
  #
  #   before_transition(
  #     %i[pending auto_accepted] => %i[accepted taken rejected deleted]
  #   ) do |version, transition|
  #     version.update moderator: transition.args.first if transition.args.first
  #   end
  #
  #   after_transition pending: %i[auto_accepted] do |version, _transition|
  #     version.fix_state if version.respond_to? :fix_state
  #   end
  #
  # #   after_transition pending: %i[accepted taken] do |version, _transition|
  # #     version.fix_state if version.respond_to? :fix_state
  # #     version.notify_acceptance
  # #   end
  #
  #   after_transition(
  #     %i[pending auto_accepted] => %i[rejected]
  #   ) do |version, transition|
  #     version.notify_rejection transition.args.second
  #   end
  #
  #   after_transition pending: :deleted do |version, _transition|
  #     version.cleanup if version.respond_to? :cleanup
  #   end
  end

  def apply_changes
    item.class.transaction do
      item_diff
        .sort_by { |(field, _changes)| field == 'desynced' ? 1 : 0 }
        .each { |(field, changes)| apply_change field, changes }
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

  def apply_transaction moderator:, **_args
    apply_changes || raise(
      AASM::InvalidTransition.new(
        self,
        transition.machine,
        transition.event
      )
    )
  end

  def assign_moderator moderator:, **_args
    self.moderator = moderator
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
