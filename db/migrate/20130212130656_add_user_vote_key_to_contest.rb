class AddUserVoteKeyToContest < ActiveRecord::Migration
  def self.up
    add_column :contests, :user_vote_key, :string
  end

  def self.down
    remove_column :contests, :user_vote_key
  end
end
