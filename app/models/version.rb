class Version < ActiveRecord::Base
  validates :item_type, :item_id, :item_diff, presence: true

  state_machine :state, initial: :pending do
    state :accepted
    state :accepted_pending
    state :rejected

    event :accept do
      transition [:pending, :accepted_pending] => :accepted
    end

    event :reject do
      transition [:pending, :accepted_pending] => :rejected
    end
  end
end
