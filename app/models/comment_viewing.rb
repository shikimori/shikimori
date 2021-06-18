class CommentViewing < ApplicationRecord
  belongs_to :user
  belongs_to :viewed,
    class_name: 'Comment',
    inverse_of: :viewings
end
