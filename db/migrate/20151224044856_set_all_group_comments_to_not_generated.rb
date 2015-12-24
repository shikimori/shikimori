class SetAllGroupCommentsToNotGenerated < ActiveRecord::Migration
  def up
    GroupComment.update_all generated: false
  end

  def down
    GroupComment.update_all generated: true
  end
end
