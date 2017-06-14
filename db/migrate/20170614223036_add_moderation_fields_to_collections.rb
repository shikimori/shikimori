class AddModerationFieldsToCollections < ActiveRecord::Migration[5.0]
  def change
    add_column :collections, :moderation_state, :string, limit: 255, default: :pending
    add_column :collections, :approver_id, :integer
  end
end
