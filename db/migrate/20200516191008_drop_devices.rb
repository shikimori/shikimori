class DropDevices < ActiveRecord::Migration[5.2]
  def up
    drop_table :devices
  end

  def down
    create_table :devices do |t|
      t.integer :user_id, null: false
      t.string :token, limit: 255, null: false
      t.integer :platform, null: false
      t.string :name, limit: 255
      t.timestamps null: false
    end
  end
end
