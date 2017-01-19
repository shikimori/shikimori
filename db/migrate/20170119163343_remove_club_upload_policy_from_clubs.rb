class RemoveClubUploadPolicyFromClubs < ActiveRecord::Migration
  def change
    remove_column :clubs, :upload_policy, :string, default: 'ByMembers'
  end
end
