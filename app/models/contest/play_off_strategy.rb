class Contest::PlayOffStrategy < Contest::DoubleEliminationStrategy
  def with_additional_rounds?
    false
  end

  def total_rounds
    @total_rounds ||= Math.log(@contest.members.count, 2).ceil
  end

  def advance_loser match
  end
end
