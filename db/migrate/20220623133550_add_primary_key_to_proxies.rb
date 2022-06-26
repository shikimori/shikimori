class AddPrimaryKeyToProxies < ActiveRecord::Migration[6.1]
  def change
    add_column :proxies, :id, :primary_key
  end
end
