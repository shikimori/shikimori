class CreateAnimes < ActiveRecord::Migration
  def self.up
    create_table :animes do |t|
      t.string :name
      t.text :description_short, :description_long, :description_mal
      t.string :atype
      t.integer :episodes
      t.integer :duration
      t.text :english, :japanese, :synonyms
      t.float :score
      t.integer :ranked, :popularity

      t.timestamps
    end
  end

  def self.down
    drop_table :animes
  end
end

