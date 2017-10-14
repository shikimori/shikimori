class AddPublisherIdsToMangas < ActiveRecord::Migration[5.1]
  def change
    add_column :mangas, :publisher_ids, :integer,
      array: true,
      null: false,
      default: []
  end
end
