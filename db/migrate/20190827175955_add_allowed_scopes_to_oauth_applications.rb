class AddAllowedScopesToOauthApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_applications, :allowed_scopes, :string, array: true, default: [], null: false
  end
end
