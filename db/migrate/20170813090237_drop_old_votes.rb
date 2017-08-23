class DropOldVotes < ActiveRecord::Migration[5.1]
  def up
    drop_table :votes_old
  end

  def down
    create_table :votes_old do |t|
      t.boolean "voting", default: false
      t.datetime "created_at", null: false
      t.integer "voteable_id"
      t.string "voteable_type", limit: 255
      t.integer "user_id"
      t.index ["user_id"], name: "index_votes_old_on_user_id"
      t.index ["voteable_id"], name: "index_votes_old_on_voteable_id"
      t.index ["voteable_type"], name: "index_votes_old_on_voteable_type"
    end
  end
end
