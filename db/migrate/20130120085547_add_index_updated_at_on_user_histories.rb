# для быстрой выборки по order(:updated_at.desc) на главной
class AddIndexUpdatedAtOnUserHistories < ActiveRecord::Migration
  def self.up
    add_index :user_histories, :updated_at
  end

  def self.down
    remove_index :user_histories, :updated_at
  end
end
