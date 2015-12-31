class RemoveUnusedFieldsFromForums < ActiveRecord::Migration
  def up
    remove_column :forums, :description
    remove_column :forums, :topics_count
    remove_column :forums, :posts_count
    remove_column :forums, :meta_title
    remove_column :forums, :meta_keywords
    remove_column :forums, :meta_description
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
