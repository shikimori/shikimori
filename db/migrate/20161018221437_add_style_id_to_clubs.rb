class AddStyleIdToClubs < ActiveRecord::Migration
  def change
    add_reference :clubs, :style, index: true
  end
end
