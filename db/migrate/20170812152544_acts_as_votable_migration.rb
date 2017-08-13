class ActsAsVotableMigration < ActiveRecord::Migration[5.1]
  def self.up
    rename_table :votes, :votes_old
    create_table :votes do |t|

      t.references :votable, polymorphic: true, null: false
      t.references :voter, polymorphic: true, null: false

      t.boolean :vote_flag
      t.string :vote_scope
      t.integer :vote_weight

      t.timestamps
    end

    add_index :votes, [:voter_id, :voter_type, :vote_scope]
    add_index :votes, [:votable_id, :votable_type, :vote_scope]
  end

  def self.down
    drop_table :votes
    rename_table :votes_old, :votes
  end
end
