class AddJoinAndCommentPolicyToClubs < ActiveRecord::Migration[5.2]
  def change
    add_column :clubs, :join_policy_new, :string
    add_column :clubs, :comment_policy_new, :string
  end
end
