class RemoveDefaultsFromCommentsFields < ActiveRecord::Migration
  def up
    change_column_default :comments, :commentable_id, nil
    change_column_default :comments, :user_id, nil
  end

  def down
    change_column_default :comments, :user_id, 0
    change_column_default :comments, :commentable_id, 0
  end
end
