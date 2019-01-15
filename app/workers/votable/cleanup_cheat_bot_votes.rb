class Votable::CleanupCheatBotVotes
  include Sidekiq::Worker

  def perform
    cheat_bot_votes.find_each do |vote|
      vote.votable.unvote_by vote.voter
    end
  end

private

  def cheat_bot_votes
    ActsAsVotable::Vote
      .where(voter_type: User.name, voter_id: User.cheat_bot)
      .includes(:voter, :votable)
  end
end
