class Contest::PlayOffStrategy < Contest::DoubleEliminationStrategy
  def with_additional_rounds?
    false
  end

  def total_rounds
    @total_rounds ||= Math.log(@contest.members.count, 2).ceil
  end

  def advance_loser match
  end

  def round_results round
    if round.next_round.nil?
      round_winners(round) + round_losers(round)
    else
      round_losers(round)
    end
  end
end
