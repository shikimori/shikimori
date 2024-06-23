class Contests::ObtainWinners
  method_object :contest

  def call
    ContestWinner.import winners
  end

private

  def winners
    results.each_with_index.map do |item, index|
      ContestWinner.new(
        contest: @contest,
        item:,
        position: index + 1
      )
    end
  end

  def results
    @contest.strategy.results(nil).take(winners_count)
  end

  def winners_count
    @contest.members.count > 64 ? 32 : 16
  end
end
