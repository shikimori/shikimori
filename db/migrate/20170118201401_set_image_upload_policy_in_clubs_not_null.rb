class SetImageUploadPolicyInClubsNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :clubs, :image_upload_policy, :string, null: false
  end
end
