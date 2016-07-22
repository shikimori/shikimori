class CommentViewing < ActiveRecord::Base
  belongs_to :user
  belongs_to :viewed, class_name: Comment.name, foreign_key: :viewed_id
end
