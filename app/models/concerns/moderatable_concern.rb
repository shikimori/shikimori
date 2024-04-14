module ModeratableConcern
  extend ActiveSupport::Concern

  included do |klass|
    include AASM
    belongs_to :approver,
      class_name: 'User',
      optional: true

    scope :pending, -> { where moderation_state: %i[pending] }
    scope :visible, -> { where moderation_state: %i[pending accepted] }

    validates :approver, presence: true, unless: :moderation_pending?

    aasm :moderation_state,
      column: 'moderation_state',
      create_scopes: false,
      namespace: :moderation do
      state Types::Moderatable::State[:pending], initial: true
      state Types::Moderatable::State[:accepted]
      state Types::Moderatable::State[:rejected]

      event :accept do
        transitions(
          from: Types::Moderatable::State[:pending],
          to: Types::Moderatable::State[:accepted],
          after: :assign_approver
        )
      end
      event :reject do
        transitions(
          from: Types::Moderatable::State[:pending],
          to: Types::Moderatable::State[:rejected],
          after: :assign_approver,
          success: :postprocess_rejection
        )
      end
      event :cancel do
        transitions(
          from: [
            Types::Moderatable::State[:accepted],
            (
              klass.const_defined?(:IS_ALLOW_MODERATABLE_REJECTED_TO_CANCEL) ?
                Types::Moderatable::State[:rejected] :
                nil
            ),
            (
              klass.const_defined?(:IS_ALLOW_MODERATABLE_CENSORED) ?
                Types::Moderatable::State[:censored] :
                nil
            )
          ].compact,
          to: Types::Moderatable::State[:pending]
        )
      end

      if klass.const_defined?(:IS_ALLOW_MODERATABLE_CENSORED)
        state Types::Moderatable::State[:censored]
        event :censore do
          transitions(
            from: Types::Moderatable::State[:pending],
            to: Types::Moderatable::State[:censored],
            after: :assign_approver
          )
        end
      end
    end
  end

private

  def assign_approver approver:
    self.approver = approver
  end

  def postprocess_rejection **_args
    return unless respond_to? :topic

    to_offtopic!

    Messages::CreateNotification
      .new(self)
      .moderatable_banned(nil)
  end

  def to_offtopic!
    topic.update_column :forum_id, Forum::OFFTOPIC_ID
  end
end
