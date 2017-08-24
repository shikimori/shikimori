class Votable::Vote
  method_object %i[votable vote voter]

  def call
    cleanup_votes if poll_vote?
    @votable.vote_by voter: @voter, vote: @vote
  end

private

  def poll_vote?
    votable.is_a? PollVariant
  end

  def cleanup_votes
    ActsAsVotable::Vote
      .where(
        voter: @voter,
        votable_type: PollVariant.name,
        votable_id: @votable.poll.variants.pluck(:id)
      )
      .destroy_all
  end
end
