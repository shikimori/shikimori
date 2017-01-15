class AddIdToMangasPublishers < ActiveRecord::Migration
  def change
    add_column :mangas_publishers, :id, :primary_key
  end
end
