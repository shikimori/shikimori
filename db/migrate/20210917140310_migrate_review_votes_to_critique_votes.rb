class MigrateReviewVotesToCritiqueVotes < ActiveRecord::Migration[5.2]
  def up
    ActsAsVotable::Vote.where(votable_type: 'Review').update_all votable_type: 'Critique'
  end

  def down
    ActsAsVotable::Vote.where(votable_type: 'Critique').update_all votable_type: 'Review'
  end
end
