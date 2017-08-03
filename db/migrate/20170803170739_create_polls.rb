class CreatePolls < ActiveRecord::Migration[5.1]
  def change
    create_table :polls do |t|
      t.references :user, null: false, index: true
      t.string :state, null: false

      t.timestamps
    end
  end
end
