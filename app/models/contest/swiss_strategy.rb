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
    else
      create_matches(
        round,
        @contest.members.size.times.map { ContestMatch::UNDEFINED },
        group: round.last? ? ContestRound::F : ContestRound::W,
        date: round.prior_round.matches.last.finished_on +
          @contest.matches_interval.days
      )
    end
  end

  def advance_members round, prior_round
    ids_to_wins = @statistics.sorted_scores

    round.matches.each do |match|
      group_half_len = top_group_length(ids_to_wins) >> 1
      rest_ids = ids_to_wins.keys
      top_half = rest_ids.shift(group_half_len)
      low_half = rest_ids.shift(group_half_len)

      left_id = top_half.shift
      right_id = (
        low_half + top_half.reverse! + rest_ids -
        @statistics.opponents_of(left_id)
      ).first

      ids_to_wins.delete left_id
      if right_id
        ids_to_wins.delete right_id
      else
        # taking key of first key=>value pair
        right_id = ids_to_wins.shift.try(:first)
      end

      match_check_and_update(match, left_id, right_id)
    end
  end

  def match_check_and_update match, left_id, right_id
    if left_id.nil?
      left_id = right_id
      right_id = nil
      # left_id should never be nil.
      # Only right_id is expected to be nil, if there are odd number of contest members
    end

    match.update!(
      left_id: left_id,
      left_type: @contest.member_klass.name,
      right_id: right_id,
      right_type: @contest.member_klass.name
    )
  end

  def top_group_length sorted_hash
    len = sorted_hash.length
    return len if len < 3

    ids = sorted_hash.keys.slice(1, len - 1)
    # we don't bother of first element's wins;
    # even with higher number of wins, it belongs to this group, not to previous

    group_wins = sorted_hash[ids.first]
    group_len = 1
    ids.each do |id|
      break unless sorted_hash[id] == group_wins
      group_len += 1
    end
    group_len
  end

  def advance_loser match
  end

  def advance_winner match
  end

  def results round = nil
    @statistics.sorted_scores(round).map do |id, scores|
      @statistics.members[id]
    end
  end
end
