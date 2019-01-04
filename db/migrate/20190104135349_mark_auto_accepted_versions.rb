class MarkAutoAcceptedVersions < ActiveRecord::Migration[5.2]
  def change
    Version
      .where('user_id = moderator_id')
      .where(state: 'accepted')
      .update_all moderator_id: nil, state: 'auto_accepted', updated_at: Time.zone.now
  end
end
