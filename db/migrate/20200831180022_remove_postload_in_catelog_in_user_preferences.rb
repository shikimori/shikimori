class RemovePostloadInCatelogInUserPreferences < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_preferences, :postload_in_catalog, :boolean,
      default: true,
      null: false
  end
end
