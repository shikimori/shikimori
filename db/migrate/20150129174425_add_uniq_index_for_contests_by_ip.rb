class AddUniqIndexForContestsByIp < ActiveRecord::Migration
  def change
    add_index :contest_user_votes, [:contest_match_id, :ip], name: :index_contest_user_votes_on_contest_vote_id_and_ip, unique: true
  end
end
