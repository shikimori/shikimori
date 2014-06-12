class SetGroupsEnumsDefaults < ActiveRecord::Migration
  def up
    Group.where(join_policy: nil).each {|v| v.update join_policy: :free_join }
    Group.where(comment_policy: nil).each {|v| v.update comment_policy: :free_comment }

    change_column :groups, :join_policy, :integer, null: false
    change_column :groups, :comment_policy, :integer, null: false

    change_column_default :groups, :join_policy, 1
    change_column_default :groups, :comment_policy, 1
  end

  def down
  end
end
