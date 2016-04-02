class RemoveTopicsWithoutComments < ActiveRecord::Migration
  def up
    Topic
      .includes(:comments)
      .where(comments: { commentable_id: nil })
      .destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
