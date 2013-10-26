class UserHistoryIndex < ActiveRecord::Migration
  def self.up
    add_index :user_histories, [:target_type, :user_id], :name => :i_user_target
  end

  def self.down
    remove_index :user_histories, :i_user_target
  end
end
