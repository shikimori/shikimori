class CreateStudios < ActiveRecord::Migration
  def self.up
    create_table :studios do |t|
      t.string :name
      t.string :short_name

      t.timestamps
    end

    create_table :animes_studios, :id => false do |t|
      t.integer :anime_id
      t.integer :studio_id
    end
  end

  def self.down
    drop_table :studios
    drop_table :animes_studios
  end
end
