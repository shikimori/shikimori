class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :user, null: false
      t.string :token, null: false
      t.integer :platform, null: false

      t.timestamps
    end
  end
end
