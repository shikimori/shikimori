class Votable::Vote
  method_object %i[votable vote voter]

  VOTE_FLAG = {
    'yes' => true,
    'no' => false,
    'abstain' => 'abstain'
  }

  CLEANUP_VOTE_SQL = <<-SQL
    (
      votable_type = '#{Poll.name}' and
      votable_id = :poll_id
    ) or (
      votable_type = '#{PollVariant.name}' and
      votable_id in (:poll_variant_ids)
    )
  SQL

  def call
    return unless can_vote? @votable
    cleanup_votes poll(@votable) if poll?(@votable)

    @votable.vote_by voter: @voter, vote: vote_flag
  end

private

  def vote_flag
    if VOTE_FLAG.key? @vote
      VOTE_FLAG[@vote]
    else
      raise ArgumentError, @vote
    end
  end

  def poll? votable
    votable.is_a?(Poll) || votable.is_a?(PollVariant)
  end

  def contest_match? votable
    votable.is_a? ContestMatch
  end

  def poll votable
    votable.is_a?(Poll) ? votable : votable.poll
  end

  def cleanup_votes poll
    ActsAsVotable::Vote
      .where(voter: @voter)
      .where(
        CLEANUP_VOTE_SQL,
        poll_id: poll.id,
        poll_variant_ids: poll.variants.pluck(:id)
      )
      .destroy_all
  end

  def can_vote? votable
    if poll?(votable)
      poll(votable).started?

    elsif contest_match?(votable)
      votable.started?
    else
      true
    end
  end
end
