class AddTitleEnToContests < ActiveRecord::Migration[5.0]
  def change
    add_column :contests, :title_en, :string, limit: 255
    rename_column :contests, :title, :title_ru
  end
end
