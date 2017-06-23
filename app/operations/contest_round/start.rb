class ContestRound::Start
  method_object :contest_round

  def call
    ContestRound.transaction { start_round }
  end

private

  def start_round
    @contest_round.start!
    @contest_round.matches
      .select { |v| v.started_on <= Time.zone.today }
      .each(&:start!)
  end
end
