class CommentViewing < ApplicationRecord
  belongs_to :user
  belongs_to :viewed, class_name: Comment.name, foreign_key: :viewed_id
end
