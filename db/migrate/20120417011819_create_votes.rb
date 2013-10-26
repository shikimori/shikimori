class CreateVotes < ActiveRecord::Migration

  def self.up
    drop_table :votes
    create_table :votes do |t|
      t.boolean :voting, :default => false
      t.datetime :created_at, :null => false
      t.references :voteable, :polymorphic => true
      t.references :user
    end

    add_index :votes, :voteable_type
    add_index :votes, :voteable_id
    add_index :votes, :user_id
  end

  def self.down
    drop_table :votes
  end

end
