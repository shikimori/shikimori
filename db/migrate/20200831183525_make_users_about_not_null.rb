class MakeUsersAboutNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :about, :text, null: false, default: ''
  end
end
