class RemoveClubUploadPolicyFromClubs < ActiveRecord::Migration[5.2]
  def change
    remove_column :clubs, :upload_policy, :string, default: 'ByMembers'
  end
end
