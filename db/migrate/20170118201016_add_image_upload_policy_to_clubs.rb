class AddImageUploadPolicyToClubs < ActiveRecord::Migration
  def change
    add_column :clubs, :image_upload_policy, :string
  end
end
