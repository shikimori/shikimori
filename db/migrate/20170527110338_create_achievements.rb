class CreateAchievements < ActiveRecord::Migration[5.0]
  def change
    create_table :achievements do |t|
      t.string :neko_id, null: false
      t.integer :level, null: false
      t.integer :progress, null: false
      t.references :user, index: true, null: false

      t.timestamps
    end
  end
end
