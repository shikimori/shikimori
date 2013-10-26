class Contest::Statistics
  def initialize contest
    @contest = contest
  end

  def sorted_scores round = nil
    Hash[scores(round).sort_by {|k,v| [-v, -average_votes(round)[k], scores(round).keys.index(k)] }]
  end

  def scores round = nil
    @scores ||= {}
    @scores[round] ||= committed_matches(round).each_with_object({}) do |match,memo|
      memo[match.left_id] ||= 0
      memo[match.right_id] ||= 0 if match.right_id

      memo[match.winner_id] += 1
    end
  end

  def users_votes round = nil
    @users_votes ||= {}
    @users_votes[round] ||= committed_matches(round).each_with_object({}) do |match,memo|
      memo[match.left_id] ||= 0
      memo[match.right_id] ||= 0 if match.right_id

      memo[match.left_id] += match.left_votes
      memo[match.right_id] += match.right_votes if match.right
    end
  end

  def average_votes round = nil
    @average_votes ||= {}
    @average_votes[round] ||= users_votes(round).each_with_object({}) do |(member_id, votes), memo|
      matches = member_matches(member_id, round).select {|v| !v.right_id.nil? }.size
      memo[member_id] = if matches.zero?
        0
      else
        (votes.to_f / matches).round 2
      end
    end
  end

  def member_matches member_id, round = nil
    committed_matches(round).select do |match|
      match.left_id == member_id || match.right_id == member_id
    end
  end

  def opponents_of member_id
    member_matches(member_id).map do |match|
      if match.left_id == member_id
        match.right_id
      elsif match.right_id == member_id
        match.left_id
      end
    end.compact
  end

  def committed_matches round = nil
    @committed_matches ||= {}
    @committed_matches[round] ||= prior_rounds(round)
      .map {|v| matches_with_associations v }
      .flatten
      .select(&:finished?)
  end

  def rounds
    @rounds ||= @contest.rounds.all#.includes(matches: [:left, :right, :votes]).all
  end

  def matches_with_associations round
    @matches ||= {}
    @matches[round] ||= round.matches.with_votes.includes(:left, :right)
  end

  def members
    @members ||= rounds
      .map {|v| matches_with_associations v }
      .flatten
      .map {|v| [v.left, v.right] }
      .flatten
      .uniq
      .compact
      .each_with_object({}) {|v,memo| memo[v.id] = v }
  end

  def prior_rounds round
    rounds.select {|v| round ? v.id <= round.id : true }
  end
end
