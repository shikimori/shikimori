class RenameStateToModerationStateInReviews < ActiveRecord::Migration[5.0]
  def change
    rename_column :critiques, :state, :moderation_state
  end
end
