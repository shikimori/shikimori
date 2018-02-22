class AddAttachmentToOauthApplications < ActiveRecord::Migration[5.1]
  def change
    add_attachment :oauth_applications, :image
  end
end
