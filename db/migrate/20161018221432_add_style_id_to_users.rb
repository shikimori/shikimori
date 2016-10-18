class AddStyleIdToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :style, index: true
  end
end
