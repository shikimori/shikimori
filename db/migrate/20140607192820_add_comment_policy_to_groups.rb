class AddCommentPolicyToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :comment_policy, :integer
  end
end
