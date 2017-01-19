class SetImageUploadPolicyInClubsNotNull < ActiveRecord::Migration
  def change
    change_column :clubs, :image_upload_policy, :string, null: false
  end
end
