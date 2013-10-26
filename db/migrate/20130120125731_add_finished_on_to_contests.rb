class AddFinishedOnToContests < ActiveRecord::Migration
  def self.up
    add_column :contests, :finished_on, :date
  end

  def self.down
    remove_column :contests, :finished_on
  end
end
