class DropForums < ActiveRecord::Migration
  def up
    drop_table :forums
  end

  def down
    create_table :forums do |t|
      t.integer :position
      t.string :name
      t.boolean :visible, default: true

      t.timestamps
    end
  end
end
