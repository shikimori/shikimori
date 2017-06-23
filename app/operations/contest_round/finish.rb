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
      finish_contest
    else
      start_next_round
    end

    # must reset @strategy becase it is cached
    @contest_round.contest.instance_variable_set('@strategy', nil)
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
    !@contest_round.next_round
  end
end
