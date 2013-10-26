# для быстрой выборки order(:updated_at.desc) на главной
class AddIndexUpdatedAtOnContests < ActiveRecord::Migration
  def self.up
    add_index :contests, :updated_at
  end

  def self.down
    remove_index :contests, :updated_at
  end
end
