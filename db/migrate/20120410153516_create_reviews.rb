class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.integer :target_id
      t.string :target_type
      t.integer :user_id
      t.text :text
      t.integer :overall
      t.integer :storyline
      t.integer :music
      t.integer :characters
      t.integer :animation

      t.timestamps
    end
    add_index :reviews, [:target_id, :target_type]
  end

  def self.down
    drop_table :reviews
  end
end
