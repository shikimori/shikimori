class ContestRound::Finish
  method_object :contest_round

  def call
    ContestRound.transaction { finish_round }
  end

private

  def finish_round
    @contest_round.matches.select(&:started?).each(&:finish!)
    @contest_round.finish!

    if last_round?
      start_next_round
    else
      finish_contest
    end
  end

  def start_next_round
    ContestRound::Start.call @contest_round.next_round
    @contest_round.strategy.advance_members(
      @contest_round.next_round,
      @contest_round
    )
    Messages::CreateNotification.new(@contest_round).round_finished
  end

  def finish_contest
    Contest::Finish.call @contest_round.contest
  end

  def last_round?
    !!@contest_round.next_round
  end
end
