class AddStyleIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :style, index: true
  end
end
