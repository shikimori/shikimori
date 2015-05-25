class AddReasonToUserChanges < ActiveRecord::Migration
  def change
    add_column :user_changes, :reason, :string
  end
end
