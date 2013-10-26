class CreateContestVotes < ActiveRecord::Migration
  def self.up
    create_table :contest_votes do |t|
      t.integer :contest_round_id
      t.string :state, default: 'created'
      t.string :group
      t.integer :left_id
      t.string :left_type
      t.integer :right_id
      t.string :right_type
      t.date :started_on
      t.date :finished_on

      t.timestamps
    end

    add_index :contest_votes, :contest_round_id
  end

  def self.down
    drop_table :contest_votes
  end
end
