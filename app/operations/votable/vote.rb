class Votable::Vote
  method_object %i[votable! vote! voter!]

  VOTE_FLAG = {
    'yes' => true,
    'no' => false,
    'abstain' => 'abstain'
  }

  CLEANUP_VOTE_SQL = <<-SQL.squish
    (
      votable_type = '#{Poll.name}' and
      votable_id = :poll_id
    ) or (
      votable_type = '#{PollVariant.name}' and
      votable_id in (:poll_variant_ids)
    )
  SQL

  def call
    return unless can_vote? @votable, @voter

    ActsAsVotable::Vote.transaction do
      cleanup_votes poll(@votable) if poll? @votable
      @votable.vote_by voter: @voter, vote: vote_flag
      update_user_key @voter, @votable if contest? @votable
    end
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

  def contest? votable
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

  def can_vote? votable, voter
    if poll?(votable)
      poll(votable).started?

    elsif contest?(votable)
      votable.started?

    else
      !(votable.respond_to?(:user_id) && votable.user_id == voter.id)
    end
  end

  def update_user_key voter, contest_match
    round_match_ids = contest_match.round.matches.select(&:started?).map(&:id)
    round_match_votes = voter.votes.where(
      votable_type: ContestMatch.name,
      votable_id: round_match_ids
    )

    if round_match_ids.size == round_match_votes.size
      voter.update contest_match.round.contest.user_vote_key => false
    end
  end
end
