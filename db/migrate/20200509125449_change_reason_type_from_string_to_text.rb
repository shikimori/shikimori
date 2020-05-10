class ChangeReasonTypeFromStringToText < ActiveRecord::Migration[5.2]
  def change
    change_column :abuse_requests, :reason, :text
    change_column :bans, :reason, :text
    change_column :versions, :reason, :text
  end
end
