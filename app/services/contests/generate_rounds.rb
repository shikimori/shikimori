class Contests::GenerateRounds
  method_object :contest

  def call
    @contest.rounds.destroy_all
    @contest.strategy.create_rounds
  end
end
