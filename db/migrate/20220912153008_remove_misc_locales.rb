class RemoveMiscLocales < ActiveRecord::Migration[6.1]
  def up
    remove_column :articles, :locale
    remove_column :clubs, :locale
    remove_column :collections, :locale
    remove_column :critiques, :locale
    remove_column :topics, :locale
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
