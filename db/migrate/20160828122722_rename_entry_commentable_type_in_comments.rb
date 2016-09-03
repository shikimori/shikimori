class RenameEntryCommentableTypeInComments < ActiveRecord::Migration
  def up
    Comment.where(commentable_type: 'Entry').update_all(commentable_type: 'Topic')
  end

  def down
    Message.where(commentable_type: 'Topic').update_all(commentable_type: 'Entry')
  end
end
