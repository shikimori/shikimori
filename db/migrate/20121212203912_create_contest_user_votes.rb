class CreateContestUserVotes < ActiveRecord::Migration
  def self.up
    create_table :contest_user_votes do |t|
      t.integer :contest_vote_id, null: false
      t.integer :user_id, null: false
      t.integer :item_id, null: false
      t.string :ip, null: false

      t.timestamps
    end

    add_index :contest_user_votes, [:contest_vote_id, :user_id], unique: true
    add_index :contest_user_votes, [:contest_vote_id, :ip], unique: true
  end

  def self.down
    drop_table :contest_user_votes
  end
end
