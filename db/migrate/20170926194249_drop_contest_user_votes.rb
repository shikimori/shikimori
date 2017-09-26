class DropContestUserVotes < ActiveRecord::Migration[5.1]
  def up
    drop_table :contest_user_votes
  end

  def down
    create_table 'contest_user_votes', id: :serial, force: :cascade do |t|
      t.integer 'contest_match_id', null: false
      t.integer 'user_id', null: false
      t.integer 'item_id', null: false
      t.string 'ip', limit: 255, null: false
      t.index %w[contest_match_id ip],
        name: 'index_contest_user_votes_on_contest_vote_id_and_ip',
        unique: true
      t.index %w[contest_match_id item_id],
        name: 'index_contest_user_votes_on_contest_vote_id_and_item_id'
      t.index %w[contest_match_id user_id],
        name: 'index_contest_user_votes_on_contest_vote_id_and_user_id',
        unique: true
    end
  end
end
