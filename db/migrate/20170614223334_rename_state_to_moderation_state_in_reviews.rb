class RenameStateToModerationStateInReviews < ActiveRecord::Migration[5.0]
  def change
    rename_column :reviews, :state, :moderation_state
  end
end
