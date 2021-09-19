class ReviewViewing < ApplicationRecord
  belongs_to :user
  belongs_to :viewed,
    class_name: 'Review',
    inverse_of: :viewings
end
