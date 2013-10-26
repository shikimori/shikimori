class CreateRelatedAnimes < ActiveRecord::Migration
  def self.up
    create_table :related_animes do |t|
      t.integer :anime_id
      t.integer :related_id
      t.string :relation

      t.timestamps
    end
  end

  def self.down
    drop_table :related_animes
  end
end
