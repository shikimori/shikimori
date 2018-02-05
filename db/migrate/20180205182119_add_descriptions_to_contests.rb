class AddDescriptionsToContests < ActiveRecord::Migration[5.1]
  def change
    add_column :contests, :description_ru, :text
    add_column :contests, :description_en, :text
  end
end
