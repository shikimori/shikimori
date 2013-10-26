class Contest::SwissStrategy < Contest::DoubleEliminationStrategy
  def dynamic_rounds?
    true
  end

  def with_additional_rounds?
    false
  end

  def total_rounds
    @total_rounds ||= Math.log(@contest.members.count, 2).ceil + 2
  end

  def fill_round_with_matches round
    if round.first?
      super
    elsif round.last?
      create_matches round, @contest.members.size.times.map { ContestMatch::Undefined }, group: ContestRound::F, date: round.prior_round.matches.last.finished_on + @contest.matches_interval.days
    else
      create_matches round, @contest.members.size.times.map { ContestMatch::Undefined }, group: ContestRound::W, date: round.prior_round.matches.last.finished_on + @contest.matches_interval.days
    end
  end

  def advance_members round, prior_round
    members_ids = @statistics.sorted_scores.keys

    round.matches.each do |match|
      left_id = members_ids.shift
      right_id = (members_ids - @statistics.opponents_of(left_id)).first
      if right_id
        members_ids.delete right_id
      else
        right_id = members_ids.shift
      end

      match.left_id = left_id
      match.left_type = @contest.member_klass.name
      match.right_id = right_id
      match.right_type = @contest.member_klass.name
      match.save!
    end
  end

  def advance_loser match
  end

  def advance_winner match
  end

  def results round = nil
    @statistics.sorted_scores(round).map {|id,scores| @statistics.members[id] }
  end
end
