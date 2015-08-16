class AddIdnexToVersions < ActiveRecord::Migration
  def change
    add_index :versions, :state
  end
end
