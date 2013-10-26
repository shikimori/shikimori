class AddUploadPolicyToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :upload_policy, :string, :default => GroupUploadPolicy::ByMembers
  end

  def self.down
    remove_column :groups, :upload_policy
  end
end
