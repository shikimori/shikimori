class Contest::DoubleEliminationStrategy
  attr_reader :statistics

  def initialize contest
    @contest = contest
    @statistics = Contest::Statistics.new @contest
  end

  def with_additional_rounds?
    true
  end

  def dynamic_rounds?
    false
  end

  def total_rounds
    @total_rounds ||= Math.log(@contest.members.count, 2).ceil * 2
  end

  def create_rounds
    number = 1
    additional = false

    total_rounds.times do |i|
      create_round number, additional

      number += 1 if !with_additional_rounds? || additional || number == 1
      additional = !additional unless i.zero? || !with_additional_rounds?
    end

    @contest.rounds.each { |v| fill_round_with_matches v }
  end

  def create_round number, additional
    @contest.rounds.create number:, additional:
  end

  def fill_round_with_matches round
    if round.first?
      create_matches(
        round,
        @contest.members,
        group: ContestRound::S,
        shuffle: true
      )

    elsif round.last?
      create_matches(
        round,
        Array.new(2) { ContestMatch::UNDEFINED },
        group: ContestRound::F,
        date: round.prior_round.matches.last.finished_on +
          @contest.matches_interval.days
      )

    else
      losers_count = [
        (round.number > 2 ?
          round.prior_round.matches.count :
          (round.prior_round.matches.sum { |v| v.right_type ? 2 : 1 } / 2.0).floor # rubocop:disable Style/NestedTernaryOperator
        ),
        1
      ].max

      winners_round =
        if round.prior_round.matches.any? do |v|
             v.group == ContestRound::W || v.group == ContestRound::S
           end
          round.prior_round
        else
          round.prior_round.prior_round
        end

      winners_count = (
        winners_round
          .matches
          .select { |v| v.group == ContestRound::W || v.group == ContestRound::S }
          .sum { |v| v.right_type ? 2 : 1 } / 2.0
      ).ceil

      if round.additional
        create_matches(
          round,
          Array.new(losers_count) { ContestMatch::UNDEFINED },
          group: ContestRound::L,
          date: round.prior_round.matches.last.finished_on +
            @contest.matches_interval.days
        )
      else
        create_matches(
          round,
          Array.new(winners_count) { ContestMatch::UNDEFINED },
          group: ContestRound::W,
          date: round.prior_round.matches.last.finished_on +
            @contest.matches_interval.days
        )

        if with_additional_rounds?
          create_matches(
            round,
            Array.new(losers_count) { ContestMatch::UNDEFINED },
            group: ContestRound::L
          )
        end
      end
    end
  end

  def create_matches round, entrires_to_fill, options
    matches = round.matches

    entrires = if options[:shuffle]
                 entrires_to_fill.shuffle
               else
                 entrires_to_fill
    end

    index = matches.count % @contest.matches_per_round
    date = options[:date] ||
      if matches.any?
        if index == 0
          matches.last.started_on + @contest.matches_interval.days
        else
          matches.last.started_on
        end
      else
        @contest.started_on
      end

    entrires.each_slice(2).each_with_index do |(left, right), pair_index|
      matches.create(
        left_type: @contest.member_klass.name,
        left_id: left && left != ContestMatch::UNDEFINED ? left.id : nil,
        right_type: right ? @contest.member_klass.name : nil,
        right_id: right && right != ContestMatch::UNDEFINED ? right.id : nil,
        group: options[:group],
        started_on: date,
        finished_on: date + [0, @contest.match_duration - 1].max.days
      )

      index += 1
      pred_last = (entrires.size / 2.0).ceil - 2
      next unless index >= @contest.matches_per_round &&
          (pair_index != pred_last || @contest.matches_per_round < 3)

      date += @contest.matches_interval.days
      index = 0
    end
  end

  def advance_members _round, prior_round
    prior_round.matches.each do |match|
      advance_winner match
      advance_loser match if match.loser
    end
  end

  def advance_winner match
    return unless match.round.next_round

    target_round =
      if match.group == ContestRound::W &&
          !match.round.additional &&
          match.round.number > 1 && match.strategy.with_additional_rounds?
        match.round.next_round.next_round
      else
        match.round.next_round
      end

    target_vote =
      if match.round.number > 1 && !match.round.additional
        target_round.matches
      elsif match.round.next_round.last?
        target_round.matches.select { |v| v.group == ContestRound::F }
      elsif match.group == ContestRound::W || match.group == ContestRound::S
        target_round.matches.select { |v| v.group == ContestRound::W }
      else
        target_round.matches.select { |v| v.group == ContestRound::L }
      end
      .find { |v| v.left_id.nil? || v.right_id.nil? }

    if target_vote.left_id.nil?
      target_vote.left = match.winner
    else
      target_vote.right = match.winner
    end

    target_vote.save
  end

  def advance_loser match
    return unless match.round.next_round
    return if match.group == ContestRound::L

    matches = match.round
      .next_round
      .matches
      .select { |v| v.group == ContestRound::L }

    if match.round.next_round.additional && match.round.next_round.number.even?
      take_order = (match.round.next_round.number / 2).even? ? :first : :last

      target_vote = matches
        .select { |v| v.right_id.nil? && v.left_type.present? }
        .send take_order
      target_vote ||= matches.select { |v| v.left_id.nil? }.send take_order

      if target_vote.right_id.nil?
        target_vote.right = match.loser
      else
        target_vote.left = match.loser
      end

    else
      target_vote = matches.find { |v| v.left_id.nil? }
      target_vote ||= matches.find { |v| v.right_id.nil? }

      if target_vote.left_id.nil?
        target_vote.left = match.loser
      else
        target_vote.right = match.loser
      end
    end

    target_vote.save
  end

  def results round = nil
    rounds = @statistics
      .prior_rounds(round)
      .reverse

    finalists =
      if round&.additional?
        Set.new intermediate_additional_results rounds.shift, rounds.shift
      else
        Set.new
      end

    rounds.each_with_object(finalists) do |round, memo|
      round_results(round).each { |v| memo << v }
    end.to_a
  end

  def round_results round
    round_winners(round) + round_losers(round)
  end

  def round_winners round
    @statistics
      .matches_with_associations(round)
      .map(&:winner)
      .compact
      .sort_by { |v| member_sorting v, round }
  end

  def round_losers round
    @statistics
      .matches_with_associations(round)
      .map(&:loser)
      .compact
      .sort_by { |v| member_sorting v, round }
  end

  def intermediate_additional_results additional_round, prior_round
    prior_g_winners = @statistics.matches_with_associations(prior_round)
      .select { |v| v.group == ContestRound::W }
      .map(&:winner)

    additional_winners = @statistics.matches_with_associations(additional_round)
      .map(&:winner)

    winners = (prior_g_winners + additional_winners)
      .sort_by { |v| member_sorting v, prior_round }

    prior_l_losers = @statistics.matches_with_associations(prior_round)
      .select { |v| v.group == ContestRound::L }
      .map(&:loser)
      .compact
      .sort_by { |v| member_sorting v, prior_round }

    additional_losers = @statistics.matches_with_associations(additional_round)
      .map(&:loser)
      .compact
      .sort_by { |v| member_sorting v, additional_round }

    winners + additional_losers + prior_l_losers
  end

  def member_sorting member, round
    -@statistics.average_votes(round)[member.id]
  end
end
