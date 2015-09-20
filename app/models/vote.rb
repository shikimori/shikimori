class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :voteable, polymorphic: true, touch: true

  validates :user, :voteable, presence: true
end
