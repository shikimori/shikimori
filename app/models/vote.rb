class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :voteable, polymorphic: true, touch: true

  validates :user, :voteable, presence: true
end
