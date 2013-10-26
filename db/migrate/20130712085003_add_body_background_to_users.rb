class AddBodyBackgroundToUsers < ActiveRecord::Migration
  def change
    add_column :users, :body_background, :string
  end
end
