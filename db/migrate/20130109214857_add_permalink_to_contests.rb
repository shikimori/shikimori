class AddPermalinkToContests < ActiveRecord::Migration
  def self.up
    add_column :contests, :permalink, :string
  end

  def self.down
    remove_column :contests, :permalink
  end
end
