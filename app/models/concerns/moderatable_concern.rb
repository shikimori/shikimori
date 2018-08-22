module ModeratableConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :approver,
      class_name: User.name,
      foreign_key: :approver_id,
      optional: true

    scope :pending, -> { where moderation_state: %w[pending] }
    scope :visible, -> { where moderation_state: %w[pending accepted] }

    state_machine :moderation_state, initial: :pending do
      state :pending
      state :accepted do
        validates :approver, presence: true
      end
      state :rejected do
        validates :approver, presence: true
      end

      event(:accept) { transition pending: :accepted }
      event(:reject) { transition pending: :rejected }

      before_transition pending: :accepted do |review, transition|
        review.approver = transition.args.first
      end

      before_transition pending: :rejected do |review, transition|
        review.approver = transition.args.first
        review.to_offtopic!

        Messages::CreateNotification.new(review)
          .moderatable_banned(transition.args.second)
      end
    end
  end

  def to_offtopic!
    topic(locale).update_column :forum_id, Forum::OFFTOPIC_ID
  end
end
