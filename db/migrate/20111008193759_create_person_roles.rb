class CreatePersonRoles < ActiveRecord::Migration
  def self.up
    create_table :person_roles do |t|
      t.string :role
      t.integer :anime_id
      t.integer :character_id
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :person_roles
  end
end
