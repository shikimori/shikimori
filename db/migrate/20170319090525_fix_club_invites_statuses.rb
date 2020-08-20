class FixClubInvitesStatuses < ActiveRecord::Migration[5.2]
  def up
    ClubInvite.where(status: 'Pending').update_all status: 'pending'
    ClubInvite.where(status: %w(Accepted Rejected)).update_all status: 'closed'
  end

  def down
    ClubInvite.where(status: 'pending').update_all status: 'Pending'
    ClubInvite.where(status: %w(closed)).update_all status: 'Rejected'
  end
end
