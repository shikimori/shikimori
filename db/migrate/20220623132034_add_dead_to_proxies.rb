class AddDeadToProxies < ActiveRecord::Migration[6.1]
  def change
    add_column :proxies, :dead, :integer, null: false, default: 0
  end
end
