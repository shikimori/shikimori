class CreateContestWinners < ActiveRecord::Migration[5.0]
  def change
    create_table :contest_winners do |t|
      t.references :contest, null: false
      t.integer :position, null: false
      t.references :item, polymorphic: true, null: false

      t.timestamps
    end
  end
end
