class AddShowHentaiImagesToUserPreferences < ActiveRecord::Migration
  def change
    add_column :user_preferences, :show_hentai_images, :boolean, default: false
  end
end
