class CreateProxies < ActiveRecord::Migration
  def self.up
    create_table :proxies, :id => false do |t|
      t.string :ip
      t.integer :port
    end
  end

  def self.down
    drop_table :proxies
  end
end
