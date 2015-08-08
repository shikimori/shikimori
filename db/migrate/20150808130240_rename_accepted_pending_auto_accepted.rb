class RenameAcceptedPendingAutoAccepted < ActiveRecord::Migration
  def up
    Version.where(state: 'accepted_pending').update_all(state: 'auto_accepted')
  end

  def down
    Version.where(state: 'auto_accepted').update_all(state: 'accepted_pending')
  end
end
