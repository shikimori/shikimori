# для быстрой выборки order(:updated_at.desc) на главной
class AddIndexUpdatedAtOnEntries < ActiveRecord::Migration
  def self.up
    add_index :entries, [:type, :updated_at]
  end

  def self.down
    remove_index :entries, [:type, :updated_at]
  end
end
