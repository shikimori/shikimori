module ModeratableConcern
  extend ActiveSupport::Concern

  included do # rubocop:disable BlockLength
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
        transitions to: Types::Moderatable::State[:accepted],
          from: Types::Moderatable::State[:pending],
          after: :fill_approver
      end
      event :reject do
        transitions to: Types::Moderatable::State[:rejected],
          from: Types::Moderatable::State[:pending]
      end
      event :cancel do
        transitions to: Types::Moderatable::State[:pending],
          from: Types::Moderatable::State[:accepted]
      end
    end

    # state_machine :moderation_state, initial: :pending do
    #   before_transition pending: :accepted do |critique, transition|
    #     critique.approver = transition.args.first
    #   end
    #
    #   before_transition pending: :rejected do |critique, transition|
    #     critique.approver = transition.args.first
    #     critique.to_offtopic!
    #
    #     Messages::CreateNotification.new(critique)
    #       .moderatable_banned(transition.args.second)
    #   end
    # end
  end

  def to_offtopic!
    topic(locale).update_column :forum_id, Forum::OFFTOPIC_ID
  end

private

  def fill_approver user
    self.approver = user
  end
end
