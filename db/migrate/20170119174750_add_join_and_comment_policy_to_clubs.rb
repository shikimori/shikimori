class AddJoinAndCommentPolicyToClubs < ActiveRecord::Migration
  def change
    add_column :clubs, :join_policy_new, :string
    add_column :clubs, :comment_policy_new, :string
  end
end
