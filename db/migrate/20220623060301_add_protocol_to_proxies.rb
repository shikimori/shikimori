class AddProtocolToProxies < ActiveRecord::Migration[6.1]
  def up
    add_column :proxies, :protocol, :string
    execute %q[update proxies set protocol='http']
    change_column_null :proxies, :protocol, false
  end

  def down
    remove_column :proxies, :protocol, :string
  end
end
