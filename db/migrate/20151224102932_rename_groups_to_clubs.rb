class RenameGroupsToClubs < ActiveRecord::Migration
  def up
    rename_table :groups, :clubs
    rename_column :clubs, :group_roles_count, :club_roles_count

    rename_table :group_roles, :club_roles
    rename_column :club_roles, :group_id, :club_id

    rename_table :group_invites, :club_invites
    rename_column :club_invites, :group_id, :club_id

    rename_table :group_links, :club_links
    rename_column :club_links, :group_id, :club_id

    rename_table :group_bans, :club_bans
    rename_column :club_bans, :group_id, :club_id

    Message.where(kind: 'GroupRequest').update_all kind: 'ClubRequest'
    Message.where(linked_type: 'GroupInvite').update_all kind: 'ClubInvite'
    Entry.where(type: 'GroupComment').update_all type: 'ClubComment'
    Entry.where(type: 'ClubComment').update_all linked_type: 'Club'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
