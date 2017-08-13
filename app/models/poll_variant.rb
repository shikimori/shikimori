class PollVariant < ApplicationRecord
  belongs_to :poll, touch: true

  acts_as_votable

  validates :text, presence: true
end
