class AddIdToMangasPublishers < ActiveRecord::Migration[5.2]
  def change
    add_column :mangas_publishers, :id, :primary_key
  end
end
