class AddDescriptionsToOauthApplications < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_applications, :description_ru, :text, null: false, default: ''
    add_column :oauth_applications, :description_en, :text, null: false, default: ''

    change_column_default :oauth_applications, :description_ru, from: '', to: nil
    change_column_default :oauth_applications, :description_en, from: '', to: nil
  end
end
