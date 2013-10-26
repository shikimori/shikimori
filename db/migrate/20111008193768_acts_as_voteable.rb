class ActsAsVoteable < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.string   :voteable_type
      t.integer  :voteable_id
      t.integer  :user_id
      t.boolean  :voting
      t.datetime :created_at
    end

    add_index :votes, [:voteable_type, :voteable_id, :user_id]
    add_index :votes, [:voteable_type, :voteable_id, :voting]
  end

  def self.down
    drop_table :votes
  end
end
