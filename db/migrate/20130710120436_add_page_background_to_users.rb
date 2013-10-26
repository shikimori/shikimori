class AddPageBackgroundToUsers < ActiveRecord::Migration
  def change
    add_column :users, :page_background, :string
  end
end
