class RemoveMiscLocales < ActiveRecord::Migration[6.1]
  def change
    remove_column :articles, :locale
    remove_column :clubs, :locale
    remove_column :collections, :locale
    remove_column :critiques, :locale
    remove_column :topics, :locale
  end
end
