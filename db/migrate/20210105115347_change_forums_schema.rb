class ChangeForumsSchema < ActiveRecord::Migration[5.2]
  def up
    change_column :forums, :position, :integer, null: false
    change_column :forums, :name_ru, :string, null: false
    change_column :forums, :name_en, :string, null: false
    change_column :forums, :permalink, :string, null: false
    change_column :forums, :created_at, :datetime, null: false
    change_column :forums, :updated_at, :datetime, null: false
  end

  def down
    change_column :forums, :position, :integer, null: true
    change_column :forums, :name_ru, :string, null: true, limit: 255
    change_column :forums, :name_en, :string, null: true
    change_column :forums, :permalink, :string, null: true, limit: 255
    change_column :forums, :created_at, :datetime, null: true
    change_column :forums, :updated_at, :datetime, null: true
  end
end
