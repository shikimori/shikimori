class AddModerationStateToPostersAndRollbackIsCensoredVerified < ActiveRecord::Migration[7.0]
  def change
    remove_column :posters, :is_censored_verified, :boolean, null: false, default: false
    add_column :posters, :moderation_state, :string, null: false, default: 'pending'
    add_reference :posters, :approver, foreign_key: { to_table: :users }, null: true
  end
end
