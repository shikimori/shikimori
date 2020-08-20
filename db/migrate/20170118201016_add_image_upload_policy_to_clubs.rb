class AddImageUploadPolicyToClubs < ActiveRecord::Migration[5.2]
  def change
    add_column :clubs, :image_upload_policy, :string
  end
end
