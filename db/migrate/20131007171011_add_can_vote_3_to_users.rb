class AddCanVote3ToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_vote_3, :boolean, default: false, null: false
  end
end
