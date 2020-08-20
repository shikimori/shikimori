class RenameClubNewJoinPolicies < ActiveRecord::Migration[5.2]
  def change
    rename_column :clubs, :join_policy_new, :join_policy
    rename_column :clubs, :comment_policy_new, :comment_policy

    change_column :clubs, :join_policy, :string, null: false
    change_column :clubs, :comment_policy, :string, null: false
  end
end
