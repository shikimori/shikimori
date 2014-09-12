class RemoveUniqIpIndexFromContestUserVotes < ActiveRecord::Migration
  def up
    remove_index :contest_user_votes, name: :index_contest_user_votes_on_contest_vote_id_and_ip
  end

  def down
    add_index :contest_user_votes, [:contest_match_id, :ip], unique: true
  end
end
