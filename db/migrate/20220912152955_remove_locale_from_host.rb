class RemoveLocaleFromHost < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :locale_from_host
  end
end
