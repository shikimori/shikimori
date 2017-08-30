class Contests::UniqVotersCount
  method_object :contest

  def call
    ActsAsVotable::Vote
      .where(votable_type: ContestMatch.name)
      .where(votable_id: contest_match_ids)
      .select('count(distinct(voter_id)) as uniq_voters')
      .to_a
      .first
      .uniq_voters
  end

private

  def contest_match_ids
    if @contest.association_cached? :rounds
      @contest.rounds.flat_map(&:matches).map(&:id)
    else
      ContestMatch
        .where(round_id: ContestRound.where(contest_id: @contest.id))
        .pluck(:id)
    end
  end
end
