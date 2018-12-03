class FixBrokenContestStartedMessage < ActiveRecord::Migration[5.2]
  def change
    Message.where(linked_id: 112, linked_type: 'Contest').update_all kind: 'ContestStarted'
  end
end
