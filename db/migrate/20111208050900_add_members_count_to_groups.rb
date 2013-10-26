class AddMembersCountToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :group_roles_count, :integer, :default => 0

    Group.reset_column_information
    Group.all.each do |group|
      Group.update_counters group.id, :group_roles_count => group.members.length
    end
  end

  def self.down
    remove_column :groups, :group_roles_count
  end
end
