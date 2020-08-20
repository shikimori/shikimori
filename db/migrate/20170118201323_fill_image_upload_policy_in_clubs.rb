class FillImageUploadPolicyInClubs < ActiveRecord::Migration[5.2]
  def change
    Club.update_all(
      image_upload_policy: Types::Club::ImageUploadPolicy[:members]
    )
  end
end
