class CreateIgnores < ActiveRecord::Migration
  def self.up
    create_table :ignores do |t|
      t.integer :user_id
      t.integer :target_id

      t.timestamps
    end
  end

  def self.down
    drop_table :ignores
  end
end
