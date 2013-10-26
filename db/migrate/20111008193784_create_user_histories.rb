class CreateUserHistories < ActiveRecord::Migration
  def self.up
    create_table :user_histories do |t|
      t.integer :user_id
      t.integer :target_id
      t.string :target_type
      t.string :action
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :user_histories
  end
end
