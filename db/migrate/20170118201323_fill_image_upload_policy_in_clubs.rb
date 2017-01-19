class FillImageUploadPolicyInClubs < ActiveRecord::Migration
  def change
    Club.update_all(
      image_upload_policy: Types::Club::ImageUploadPolicy[:members]
    )
  end
end
