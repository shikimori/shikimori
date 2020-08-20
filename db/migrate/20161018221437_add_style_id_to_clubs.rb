class AddStyleIdToClubs < ActiveRecord::Migration[5.2]
  def change
    add_reference :clubs, :style, index: true
  end
end
