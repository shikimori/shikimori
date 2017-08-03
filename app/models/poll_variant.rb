class PollVariant < ApplicationRecord
  belongs_to :poll, touch: true

  acts_as_voteable

  validates :text, presence: true
end
